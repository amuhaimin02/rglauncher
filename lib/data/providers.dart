import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/data/tasks.dart';
import 'package:rglauncher/main.dart';
import 'package:rglauncher/utils/extensions.dart';

import '../utils/config_loader.dart';
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

final allSystemsProvider = FutureProvider(
  (ref) async {
    final data = await loadConfigFromAsset('config/systems.toml');
    return data.entries
        .map((e) => System.fromMap({...e.value, 'code': e.key}))
        .toList();
  },
);

final allEmulatorsProvider = FutureProvider(
  (ref) async {
    final data = await loadConfigFromAsset('config/emulators.toml');
    return data.entries
        .map((e) => Emulator.fromMap({...e.value, 'code': e.key}))
        .toList();
  },
);

final selectedSystemIndexProvider = StateProvider((ref) => 0);

final selectedMenuIndexProvider = StateProvider((ref) => 0);

final selectedGameListIndexProvider = StateProvider((ref) => 0);

final selectedSystemProvider = FutureProvider((ref) async {
  final systems = await ref.watch(allSystemsProvider.future);
  return systems[ref.watch(selectedSystemIndexProvider)];
});

final selectedGameProvider = FutureProvider((ref) async {
  final system = await ref.watch(selectedSystemProvider.future);
  final library = await ref.watch(gameLibraryProvider.future);
  final index = ref.watch(selectedGameListIndexProvider);
  return library[system]?.get(index);
});

final gameLibraryProvider = FutureProvider((ref) async {
  final result = await compute(scanLibrariesFromStorageCompute, {
    'systems': await ref.read(allSystemsProvider.future),
    'storagePaths': [Directory('/storage/emulated/0/EmuROM')]
  });
  return result;
});

final currentBackgroundImageProvider =
    StateProvider<ImageProvider?>((ref) => null);
