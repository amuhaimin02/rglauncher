import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/features/media_manager.dart';
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
    return db.allSystems();
  },
);

final systemEmulatorsProvider = FutureProvider.family<List<Emulator>, String>(
  (ref, systemCode) async {
    final db = services<Database>();
    return db.allEmulatorsBySystemCode(systemCode);
  },
);

final selectedSystemIndexProvider = StateProvider((ref) => 0);

final selectedMenuIndexProvider = StateProvider((ref) => 0);

final selectedGameListIndexProvider = StateProvider((ref) => 0);

final selectedSystemProvider = FutureProvider((ref) async {
  final systems = await ref.watch(scannedSystemProvider.future);
  return systems[ref.watch(selectedSystemIndexProvider)];
});

final selectedGameProvider = FutureProvider((ref) async {
  final system = await ref.watch(selectedSystemProvider.future);
  final library = await ref.watch(gameLibraryProvider(system).future);
  final index = ref.watch(selectedGameListIndexProvider);
  return library.get(index);
});

final scannedSystemProvider = FutureProvider((ref) async {
  final database = services<Database>();
  return database.scannedSystems();
});

final gameLibraryProvider =
    FutureProvider.family<List<Game>, System>((ref, system) async {
  final db = services<Database>();
  return db.allGamesBySystem(system);
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

final favoritedGamesProvider = FutureProvider((ref) async {
  final db = services<Database>();
  return db.getFavoritedGames();
});

final wishlistedGamesProvider = FutureProvider((ref) async {
  final db = services<Database>();
  return db.getWishlistedGames();
});

final recentGamesProvider = FutureProvider((ref) async {
  final db = services<Database>();
  return db.getRecentGames();
});

final newlyAddedGamesProvider = FutureProvider((ref) async {
  final db = services<Database>();
  return db.getNewlyAddedGames();
});

final pinnedGamesProvider = FutureProvider((ref) async {
  final db = services<Database>();
  return db.getPinnedGames();
});

final continueGameProvider = FutureProvider((ref) async {
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
  appList.shuffle();
  return appList.take(6).cast<ApplicationWithIcon>();
});

final notificationProvider =
    StateNotifierProvider<NotificationManager, NotificationMessage?>(
  (ref) => NotificationManager(),
);
