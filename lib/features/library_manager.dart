import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:rglauncher/features/scraper.dart';
import 'package:rglauncher/features/storage.dart';

import '../data/models.dart';
import '../data/typedefs.dart';
import '../utils/config_loader.dart';
import 'media_manager.dart';
import 'services.dart';

class LibraryManager {
  const LibraryManager();

  Future<void> preloadData() async {
    final storage = services<Storage>();
    final systemConfig = await loadConfigFromAsset('config/systems.toml');
    final systems = systemConfig.entries
        .map((e) => System.fromMap({...e.value, 'code': e.key}))
        .toList();
    storage.systemBox.removeAll();
    storage.systemBox.putMany(systems);

    final emulatorConfig = await loadConfigFromAsset('config/emulators.toml');
    final emulators = emulatorConfig.entries
        .map((e) => Emulator.fromMap({...e.value, 'code': e.key}))
        .toList();
    storage.emulatorBox.removeAll();
    storage.emulatorBox.putMany(emulators);
  }

  Future<void> scanLibrariesFromStorage({
    required List<System> systems,
    required List<Directory> storagePaths,
  }) async {
    services<Storage>().gameBox.removeAll();
    final scannedGames = await compute(
      _doScanLibraryFromStorage,
      {
        'systems': systems.map((e) => e.toMap()).toList(),
        'storagePaths': storagePaths,
      },
    );
    services<Storage>().gameBox.putMany(scannedGames);
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

Future<List<Game>> _doScanLibraryFromStorage(JsonMap args) async {
  final systems = args['systems'] as List<JsonMap>;
  final storagePaths = args['storagePaths'] as List<Directory>;

  // final status = await Permission.manageExternalStorage.request();
  final gameLists = <JsonMap, List<Game>>{};
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system['folders']) folderName: system
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

  final sortedGameLists = <JsonMap, List<Game>>{};
  for (final system in systems) {
    if (gameLists[system] != null) {
      // Sort systems based on position
      sortedGameLists[system] = gameLists[system]!;

      // Sort games based on name
      sortedGameLists[system]!.sort((a, b) => a.name.compareTo(b.name));
    }
  }
  return sortedGameLists.values.flattened.toList();
  // return sortedGameLists;
}

List<Game> _doScanDirectoriesForGames(
  JsonMap system,
  Directory directory,
) {
  final matcher = RegExp(
    '(${system['extensions'].join('|')})\$',
    caseSensitive: false,
  );

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => matcher.hasMatch(file.path))
      .map((file) => Game(
            name: basename(file.path),
            filepath: file.path,
            // system: system,
          ))
      .toList();
}
