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
    final db = services<AppDatabase>();
    return db.allSystems();
  },
);

final allEmulatorsProvider = FutureProvider(
  (ref) async {
    final db = services<AppDatabase>();
    return db.allEmulators();
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
  final system = await ref.watch(allSystemsProvider.future);
  return services<MediaManager>().getSavedGameList(system);
});

final gameLibraryProvider =
    FutureProvider.family<List<Game>, System>((ref, system) async {
  final db = services<AppDatabase>();
  return db.allGamesBySystem(system);
  // return await services<CsvStorage>().loadCsvFromFile(
  //   services<MediaManager>().getGameListFile(system),
  //   (line) => Game(
  //     name: line[0] as String,
  //     filepath: line[1] as String,
  //     system: system,
  //   ),
  // );
  // return {
  //   for (final s in systems)
  //     s: await () async {
  //       try {
  //         return await services<CsvStorage>().loadCsvFromFile(
  //           services<MediaManager>().getGameListFile(s),
  //           (line) => Game(
  //               name: line[0] as String,
  //               filepath: line[1] as String,
  //               system: s),
  //         );
  //       } on FileSystemException catch (e) {
  //         return <Game>[];
  //       }
  //     }()
  // };
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

final pinnedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final systems = await ref.watch(allSystemsProvider.future);
  final gba = systems.firstWhere((s) => s.code == 'GBA');
  final library = await ref.watch(gameLibraryProvider(gba).future);
  return library.take(4).toList();
});

final notificationProvider =
    StateNotifierProvider<NotificationManager, NotificationMessage?>(
  (ref) => NotificationManager(),
);
