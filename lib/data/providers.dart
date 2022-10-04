import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/utils/extensions.dart';

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
  (ref) => [
    const System(
      name: 'Entertainment System',
      code: 'NES',
      description:
          'The Nintendo Entertainment System (NES) is an 8-bit third-generation home video game console produced by Nintendo. It was first released in Japan in 1983 as the Family Computer (FC), commonly known as the Famicom. The NES, a redesigned version, was released in American test markets in October 1985, before becoming widely available in North America and other countries.',
      producer: 'Nintendo',
    ),
    const System(
      name: 'Game Boy Advance',
      code: 'GBA',
      description:
          'The Game Boy Advance (GBA) is a 32-bit handheld game console developed, manufactured and marketed by Nintendo as the successor to the Game Boy Color. It was released in Japan on March 21, 2001, in North America on June 11, 2001, in the PAL region on June 22, 2001, and in mainland China as iQue Game Boy Advance on June 8, 2004. The GBA is part of the sixth generation of video game consoles.',
      producer: 'Nintendo',
    ),
    const System(
      name: 'PlayStation',
      code: 'PSX',
      description:
          'PlayStation (Japanese: プレイステーション, Hepburn: Pureisutēshon, officially abbreviated as PS) is a video game brand that consists of five home video game consoles, two handhelds, a media center, and a smartphone, as well as an online service and multiple magazines. The brand is produced by Sony Interactive Entertainment, a division of Sony; the first PlayStation console was released in Japan in December 1994, and worldwide the following year.',
      producer: 'Sony',
    ),
  ],
);

final selectedSystemIndexProvider = StateProvider((ref) => 0);

final selectedMenuIndexProvider = StateProvider((ref) => 0);

final selectedGameListIndexProvider = StateProvider((ref) => 0);

final selectedSystemProvider = StateProvider(
  (ref) =>
      ref.watch(allSystemsProvider)[ref.watch(selectedSystemIndexProvider)],
);
