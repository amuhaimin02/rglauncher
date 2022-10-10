import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/features/scraper.dart';

import '../data/typedefs.dart';
import '../utils/config_loader.dart';
import 'media_manager.dart';
import 'services.dart';

class LibraryManager {
  const LibraryManager();

  Future<void> preloadData() async {
    final db = services<AppDatabase>();
    final systemConfig = await loadConfigFromAsset('config/systems.toml');
    final systemList = systemConfig.entries
        .map((e) => System(
              name: e.value['name'] as String,
              code: e.key,
              producer: e.value['producer'] as String,
              thumbnailLink: e.value['image'] as String,
              folderNames: (e.value['folders'] as List).cast<String>(),
              supportedExtensions:
                  (e.value['extensions'] as List).cast<String>(),
            ))
        .toList();

    await db.updateSystems(systemList);

    final emulatorConfig = await loadConfigFromAsset('config/emulators.toml');
    final emulatorList = emulatorConfig.entries
        .map((e) => Emulator(
              name: e.value['name'] as String,
              code: e.key,
              executable: e.value['executable'] as String,
              system: e.value['for'] as String,
              libretroPath: e.value['libretro'] as String?,
            ))
        .toList();

    await db.updateEmulators(emulatorList);
  }

  Future<void> scanLibrariesFromStorage({
    required List<System> systems,
    required List<Directory> storagePaths,
  }) async {
    final gameList = await compute(
      _doScanLibraryFromStorage,
      {
        'mediaManager': services<MediaManager>(),
        'systems': systems,
        'storagePaths': storagePaths,
      },
    );
    final db = services<AppDatabase>();
    await db.refreshGames(gameList
        .map(
          (g) => GamesCompanion.insert(
            name: g.name,
            filepath: g.filepath,
            system: g.system,
          ),
        )
        .toList());
  }

  Future<void> downloadAndStoreSystemImages(
      {required List<System> systems}) async {
    final manager = services<MediaManager>();
    for (final system in systems) {
      final imageBytes = await manager.downloadImage(system.thumbnailLink);
      manager.saveSystemImageFile(imageBytes, system);
    }
  }

  Future<void> scrapeAndStoreGameImages({
    required List<Game> games,
    required Function(int index)? progress,
  }) async {
    final progressPort = ReceivePort();
    progressPort.listen((message) {
      progress?.call(message as int);
    });
    await compute(
      _doScrapeAndStoreGameImages,
      {
        'mediaManager': services<MediaManager>(),
        'games': games,
        'progressPort': progressPort.sendPort,
      },
    );
    progressPort.close();
  }
}

// Isolate-based tasks

Future<void> _doScrapeAndStoreGameImages(JsonMap args) async {
  final games = args['games'] as List<Game>;
  final manager = args['mediaManager'] as MediaManager;
  final progressPort = args['progressPort'] as SendPort;

  int gameProcessed = 0;
  final scraper = DummyScraper();
  for (final game in games) {
    progressPort.send(gameProcessed++);
    // progress?.call(game);

    if (!manager.isGameMediaFileExists(game)) {
      final imageLink = scraper.getBoxArtImageLink(game);
      final imageBytes = await manager.downloadImage(imageLink);
      manager.saveGameMediaFile(imageBytes, game);
    } else {
      // Skipping
    }
  }
}

Future<List<Game>> _doScanLibraryFromStorage(JsonMap args) async {
  final systems = args['systems'] as List<System>;
  final storagePaths = args['storagePaths'] as List<Directory>;
  final mediaManager = args['mediaManager'] as MediaManager;

  // final status = await Permission.manageExternalStorage.request();
  final gameLists = <Game>[];
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system.folderNames) folderName: system
  };

  for (final path in storagePaths) {
    final folderList = path.listSync(recursive: true).whereType<Directory>();
    for (final folder in folderList) {
      final system = folderToSystemMap[basename(folder.path)];
      if (system != null) {
        gameLists.addAll(
          _doScanDirectoriesForGames(system, folder),
        );
      }
    }
  }
  return gameLists;
}

List<Game> _doScanDirectoriesForGames(
  System system,
  Directory directory,
) {
  final matcher = RegExp(
    '(${system.supportedExtensions.join('|')})\$',
    caseSensitive: false,
  );

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => matcher.hasMatch(file.path))
      .map((file) => Game(
    id: 0,
            name: basename(file.path),
            filepath: file.path,
            system: system.code,
          ))
      .toList();
}
