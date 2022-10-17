import 'package:battery_plus/battery_plus.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/features/notification_manager.dart';
import 'package:rglauncher/features/services.dart';
import 'package:rglauncher/utils/extensions.dart';

import '../widgets/command.dart';
import 'database.dart';
import 'models.dart';

final routeObserverProvider = Provider((ref) => RouteObserver<PageRoute>());

final batteryProvider = Provider((ref) => Battery());

final batteryLevelProvider = StreamProvider.autoDispose<int>((ref) {
  final battery = ref.watch(batteryProvider);
  return onceAndPeriodic(
    const Duration(seconds: 10),
    (count) {
      return battery.batteryLevel;
    },
  ).asyncMap((event) async => await event);
});

// final batteryStateProvider = StreamProvider.autoDispose<BatteryState>((ref) {
//   return ref.watch(batteryProvider).onBatteryStateChanged;
// });

final connectivityStateProvider =
    StreamProvider.autoDispose<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

final commandProvider = StateProvider<List<Command>>((ref) => []);

final allSystemsProvider = FutureProvider(
  (ref) async {
    final db = services<Database>();
    return db.getAllSystems();
  },
);

final systemEmulatorsProvider = FutureProvider.family<List<Emulator>, String>(
  (ref, systemCode) async {
    final db = services<Database>();
    return db.allEmulatorsBySystemCode(systemCode);
  },
);

final selectedMenuIndexProvider = StateProvider((ref) => 0);

final selectedSystemProvider = StateProvider<System?>((ref) => null);

final selectedGameProvider = StateProvider<Game?>((ref) => null);

final selectedGameMetadataProvider = Provider((ref) {
  final db = services<Database>();
  final game = ref.watch(selectedGameProvider);
  if (game == null) return null;
  final meta = db.getMetadataForGame(game);
  return meta;
});

final scannedSystemProvider = StreamProvider((ref) {
  final database = services<Database>();
  return database.getScannedSystems();
});

final gameLibraryProvider =
    StreamProvider.family<List<Game>, System>((ref, system) {
  final db = services<Database>();
  return db.getGamesBySystem(system);
});

final allGamesProvider = FutureProvider((ref) async {
  final scannedSystems = await ref.watch(scannedSystemProvider.future);
  final allGames = <Game>[];
  for (final system in scannedSystems) {
    final systemGames = await ref.watch(gameLibraryProvider(system).future);
    allGames.addAll(systemGames);
  }
  return allGames;
});

final favoritedGamesProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getFavoritedGames();
});

final wishlistedGamesProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getWishlistedGames();
});

final recentGamesProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getRecentGames();
});

final newlyAddedGamesProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getNewlyAddedGames();
});

final pinnedGamesProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getPinnedGames();
});

final continueGameProvider = StreamProvider((ref) {
  final db = services<Database>();
  return db.getLastPlayedGame();
});

final currentBackgroundImageProvider =
    StateProvider<ImageProvider?>((ref) => null);

final installedAppsProvider = FutureProvider((ref) async {
  final appList = await DeviceApps.getInstalledApplications(
    onlyAppsWithLaunchIntent: true,
    includeSystemApps: true,
    includeAppIcons: true,
  );
  return appList.cast<ApplicationWithIcon>().sortedBy((a) => a.appName);
});

final pinnedAppsProvider = StreamProvider.autoDispose((ref) async* {
  final allApps = await ref.watch(installedAppsProvider.future);
  final db = services<Database>();
  await for (final pinnedApps in db.getPinnedApps()) {
    final packageNames = pinnedApps.map((e) => e.packageName);
    yield allApps.where((app) => packageNames.contains(app.packageName));
  }
});

final notificationProvider =
    StateNotifierProvider<NotificationManager, NotificationMessage?>(
  (ref) => NotificationManager(),
);
