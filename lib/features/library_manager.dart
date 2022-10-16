import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/features/media_scraper.dart';

import '../data/models.dart';
import '../data/typedefs.dart';
import '../utils/config_loader.dart';
import 'media_manager.dart';
import 'services.dart';

class LibraryManager {
  const LibraryManager();

  Future<void> preloadData() async {
    final status = await Permission.manageExternalStorage.request();

    final db = services<Database>();
    final systemConfig = await loadConfigFromAsset('config/systems.toml');
    final systemList = systemConfig.entries
        .map((e) => System()
          ..name = e.value['name'] as String
          ..code = e.key
          ..producer = e.value['producer'] as String
          ..thumbnailLink = e.value['image'] as String
          ..folderNames = (e.value['folders'] as List).cast<String>()
          ..extensions = (e.value['extensions'] as List).cast<String>())
        .toList();

    await db.updateSystems(systemList);

    final emulatorConfig = await loadConfigFromAsset('config/emulators.toml');
    final emulatorList = emulatorConfig.entries
        .map((e) => Emulator()
          ..name = e.value['name'] as String
          ..code = e.key
          ..executable = e.value['executable'] as String
          ..systemCode = e.value['for']
          ..libretroPath = e.value['libretro'] as String?)
        .toList();

    await db.updateEmulators(emulatorList);

    await downloadAndStoreSystemImages(systems: systemList);
  }

  Future<void> scanLibrariesFromStorage({
    required List<Directory> storagePaths,
  }) async {
    return await compute(
      _doScanLibraryFromStorage,
      {
        'storagePaths': storagePaths,
      },
    );
  }

  Future<void> downloadAndStoreSystemImages(
      {required List<System> systems}) async {
    final manager = services<MediaManager>();
    for (final system in systems) {
      final file = manager.getSystemImageFile(system);
      if (!file.existsSync()) {
        final imageBytes = await manager.downloadImage(system.thumbnailLink);
        manager.saveSystemImageFile(imageBytes, system);
      }
    }
  }

  Future<void> scrapeAndStoreGameImages({
    required Function(String gameFileName)? progress,
  }) async {
    final progressPort = ReceivePort();
    progressPort.listen((message) {
      progress?.call(message as String);
    });
    await compute(
      _doScrapeAndStoreGameImages,
      {
        'mediaManager': services<MediaManager>(),
        'progressPort': progressPort.sendPort,
        ...dotenv.env
      },
    );
    progressPort.close();
  }
}

// Isolate-based tasks

Future<void> _doScrapeAndStoreGameImages(JsonMap args) async {
  final manager = args['mediaManager'] as MediaManager;
  final progressPort = args['progressPort'] as SendPort;
  final db = await Database.open(temporary: true);
  final games = await db.getAllGames();

  int gameProcessed = 0;
  final scraper = ScreenScraperMediaScraper(
    devId: args['SCREENSCRAPERFR_DEV_ID'],
    devPassword: args['SCREENSCRAPERFR_DEV_PASSWORD'],
  );
  for (final game in games) {
    progressPort.send(game.filename);
    // progress?.call(game);

    print('Finding ${game.filename}');
    if (manager.getGameScreenshotFile(game).existsSync() &&
        manager.getGameBoxArtFile(game).existsSync() &&
        (await db.getMetadataForGame(game)) != null) {
      print('Skipping');
      continue;
    }

    final data = await scraper.find(game, manager);
    if (data == null) {
      print('Not found');
      continue;
    }
    print('Found: ${data.metadata.title}');

    await db.saveGameMetadata(game, data.metadata);
    if (data.boxArtImage != null) {
      manager.saveFile(data.boxArtImage!, manager.getGameBoxArtFile(game));
    }
    if (data.screenshotImage != null) {
      manager.saveFile(
          data.screenshotImage!, manager.getGameScreenshotFile(game));
    }
  }
}

Future<void> _doScanLibraryFromStorage(JsonMap args) async {
  final storagePaths = args['storagePaths'] as List<Directory>;
  final database = await Database.open(temporary: true);
  final systems = await database.getAllSystems();

  final gameLists = <Game>[];
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system.folderNames) folderName: system
  };

  for (final path in storagePaths) {
    final folderList = path.listSync().whereType<Directory>();
    for (final folder in folderList) {
      final system = folderToSystemMap[basename(folder.path)];
      if (system != null) {
        gameLists.addAll(
          _doScanDirectoriesForGames(system, folder),
        );
      }
    }
  }

  await database.refreshGames(gameLists);
}

List<Game> _doScanDirectoriesForGames(
  System system,
  Directory directory,
) {
  final matcher = RegExp(
    '(${system.extensions.join('|')})\$',
    caseSensitive: false,
  );

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => matcher.hasMatch(file.path))
      .map((file) => Game()
        ..name = basename(file.path)
        ..filename = basename(file.path)
        ..filepath = file.parent.path
        ..systemCode = system.code)
      .toList();
}
