import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/features/notification_manager.dart';
import 'package:rglauncher/features/services.dart';
import 'package:rglauncher/utils/extensions.dart';

import '../features/storage.dart';
import '../widgets/command.dart';

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

final allSystemsProvider = Provider(
  (ref) {
    return services<Storage>().systemBox.getAll();
  },
);

final allEmulatorsProvider = Provider(
  (ref) {
    return services<Storage>().emulatorBox.getAll();
  },
);

final selectedSystemIndexProvider = StateProvider((ref) => 0);

final selectedMenuIndexProvider = StateProvider((ref) => 0);

final selectedGameListIndexProvider = StateProvider((ref) => 0);

final selectedSystemProvider = FutureProvider((ref) async {
  final systems = ref.watch(allSystemsProvider);
  return systems[ref.watch(selectedSystemIndexProvider)];
});

final selectedGameProvider = FutureProvider((ref) async {
  final system = await ref.watch(selectedSystemProvider.future);
  final library = await ref.watch(gameLibraryProvider.future);
  final index = ref.watch(selectedGameListIndexProvider);
  return library[system]?.get(index);
});

final gameLibraryProvider = FutureProvider((ref) async {
  final systems = ref.read(allSystemsProvider);
  final allGames = services<Storage>().gameBox.getAll();
  print(allGames.first.system);
  return {
    systems.first: allGames,
  };
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
  final library = await ref.watch(gameLibraryProvider.future);
  final systems = ref.watch(allSystemsProvider);
  final gba = systems.firstWhere((s) => s.code == 'GBA');
  return library[gba]?.take(4).toList() ?? <Game>[];
});

final notificationProvider =
    StateNotifierProvider<NotificationManager, NotificationMessage?>(
  (ref) => NotificationManager(),
);
