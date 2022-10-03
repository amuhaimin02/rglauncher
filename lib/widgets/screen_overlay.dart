import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import 'command.dart';

class ScreenOverlay extends StatelessWidget {
  const ScreenOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: const [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: DeviceStatusInfo(),
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: CommandInfo(),
          ),
        ],
      ),
    );
  }
}

class DeviceStatusInfo extends ConsumerWidget {
  const DeviceStatusInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryLevel = ref.watch(batteryLevelProvider);
    // final batteryState = ref.watch(batteryStateProvider);
    final connectivityState = ref.watch(connectivityStateProvider);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          connectivityState.when(
            data: (state) => const Icon(Icons.wifi),
            error: (error, stack) => const SizedBox(),
            loading: () => const SizedBox(),
          ),
          // const SizedBox(width: 8),
          // batteryState.when(
          //   data: (state) => const Icon(Icons.battery_5_bar_outlined),
          //   error: (error, stack) => const SizedBox(),
          //   loading: () => const SizedBox(),
          // ),
          const SizedBox(width: 8),
          batteryLevel.when(
            data: (level) => Text(
              '$level %',
              style: textTheme.labelLarge,
            ),
            error: (error, stack) => const SizedBox(),
            loading: () => const SizedBox(),
          )
        ],
      ),
    );
  }
}
