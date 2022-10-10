import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/features/csv_storage.dart';
import 'package:rglauncher/features/scraper.dart';

import '../data/models.dart';
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
              imageLink: e.value['image'] as String,
              folderNames: (e.value['folders'] as List).cast<String>(),
              supportedExtensions:
                  (e.value['extensions'] as List).cast<String>(),
            ))
        .toList();

    await db.systems.addAll(systemList);

    final emulatorConfig = await loadConfigFromAsset('config/emulators.toml');
    final emulatorList = emulatorConfig.entries
        .map((e) => Emulator(
              name: e.value['name'] as String,
              code: e.key,
              executable: e.value['executable'] as String,
              forSystem: e.value['for'] as String,
              libretroPath: e.value['libretro'] as String?,
            ))
        .toList();

    await db.emulators.addAll(emulatorList);
  }

  Future<void> scanLibrariesFromStorage({
    required List<System> systems,
    required List<Directory> storagePaths,
  }) async {
    await compute(
      _doScanLibraryFromStorage,
      {
        'csvStorage': services<CsvStorage>(),
        'mediaManager': services<MediaManager>(),
        'systems': systems,
        'storagePaths': storagePaths,
      },
    );
  }

  Future<void> downloadAndStoreSystemImages(
      {required List<System> systems}) async {
    final manager = services<MediaManager>();
    for (final system in systems) {
      final imageBytes = await manager.downloadImage(system.imageLink);
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

Future<void> _doScanLibraryFromStorage(JsonMap args) async {
  final systems = args['systems'] as List<System>;
  final storagePaths = args['storagePaths'] as List<Directory>;
  final storage = args['csvStorage'] as CsvStorage;
  final mediaManager = args['mediaManager'] as MediaManager;

  // final status = await Permission.manageExternalStorage.request();
  final gameLists = <System, List<Game>>{};
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system.folderNames) folderName: system
  };

  for (final path in storagePaths) {
    final folderList = path.listSync(recursive: true).whereType<Directory>();
    for (final folder in folderList) {
      final system = folderToSystemMap[basename(folder.path)];
      if (system != null) {
        if (gameLists[system] == null) {
          gameLists[system] = [];
        }
        gameLists[system]!.addAll(_doScanDirectoriesForGames(system, folder));
      }
    }
  }

  final sortedGameLists = <System, List<Game>>{};
  for (final system in systems) {
    if (gameLists[system] != null && gameLists[system]!.isNotEmpty) {
      // Sort systems based on position
      sortedGameLists[system] = gameLists[system]!;

      // Sort games based on name
      sortedGameLists[system]!.sort((a, b) => a.name.compareTo(b.name));
      storage.saveCsvToFile<Game>(
        mediaManager.getGameListFile(system),
        sortedGameLists[system]!,
        (item) => [item.name, item.filepath],
      );
    }
  }
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
            name: basename(file.path),
            filepath: file.path,
            system: system,
          ))
      .toList();
}
