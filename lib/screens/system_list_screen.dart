import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/features/services.dart';
import 'package:rglauncher/screens/game_list_screen.dart';
import 'package:rglauncher/widgets/loading_spinner.dart';
import 'package:rglauncher/widgets/small_label.dart';

import '../data/configs.dart';
import '../data/models.dart';
import '../utils/navigate.dart';
import '../widgets/command.dart';
import '../widgets/gamepad_listener.dart';
import '../widgets/launcher_scaffold.dart';

class SystemListScreen extends ConsumerWidget {
  const SystemListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannedSystems = ref.watch(scannedSystemProvider);
    return scannedSystems.when(
      loading: () => const LoadingSpinner(),
      error: (error, stack) => Text(error.toString()),
      data: (systems) {
        final system = systems[ref.watch(selectedSystemIndexProvider)];
        return LauncherScaffold(
          backgroundImage:
              FileImage(services<MediaManager>().getSystemImageFile(system)),
          body: CommandWrapper(
            commands: [
              Command(
                button: CommandButton.a,
                label: 'Open',
                onTap: () => _openGameListScreen(context),
              ),
              Command(
                button: CommandButton.b,
                label: 'Back',
                onTap: () => Navigate.back(),
              ),
            ],
            child: GamepadListener(
              key: const ValueKey('system'),
              onDirectional: (direction, repeating) {
                // int itemSize = ref.read(allSystemsProvider).length;
                // if (direction == GamepadDirection.left) {
                //   rangeLimit(
                //     value: ref.read(selectedSystemIndexProvider) - 1,
                //     max: itemSize,
                //     ifInRange: () =>
                //         ref.read(selectedSystemIndexProvider.state).state--,
                //   );
                // } else if (direction == GamepadDirection.right) {
                //   rangeLimit(
                //     value: ref.read(selectedSystemIndexProvider) + 1,
                //     max: itemSize,
                //     ifInRange: () =>
                //         ref.read(selectedSystemIndexProvider.state).state++,
                //   );
                // }
              },
              onA: () => _openGameListScreen(context),
              child: const SystemPageView(),
            ),
          ),
        );
      },
    );
  }

  void _openGameListScreen(BuildContext context) {
    Navigate.to(
      (context) => const GameListScreen(),
      direction: Axis.vertical,
    );
  }
}

class SystemPageView extends ConsumerStatefulWidget {
  const SystemPageView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SystemPageView> createState() => _SystemPageViewState();
}

class _SystemPageViewState extends ConsumerState<SystemPageView> {
  late final _pageController = PageController(
    viewportFraction: _calculateViewportFraction(),
    initialPage: ref.watch(selectedSystemIndexProvider),
  );

  double _calculateViewportFraction() {
    final screenSize = MediaQuery.of(context).size;
    final viewportFraction = screenSize.height / screenSize.width;
    return viewportFraction * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final currentSystemIndex = ref.watch(selectedSystemIndexProvider);
    final scannedSystems = ref.watch(scannedSystemProvider);

    ref.listen(selectedSystemIndexProvider, (prevIndex, newIndex) {
      _pageController.animateToPage(
        newIndex,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });

    return scannedSystems.when(
      error: (error, stack) => Text('$error\n$stack'),
      loading: () => const LoadingSpinner(),
      data: (systems) {
        return Column(
          children: [
            Expanded(
              flex: 6,
              child: GameSystemDetail(
                system: systems[currentSystemIndex],
              ),
            ),
            Expanded(
              flex: 6,
              child: PageView(
                controller: _pageController,
                children: [
                  for (int i = 0; i < systems.length; i++)
                    SystemItemTile(
                      selected: currentSystemIndex == i,
                      onTap: () => _openGameListScreen(context, i),
                      system: systems[i],
                    ),
                ],
                onPageChanged: (index) {
                  ref.read(selectedSystemIndexProvider.state).state = index;
                },
              ),
            ),
            const Spacer(flex: 2)
          ],
        );
      },
    );
  }

  void _openGameListScreen(BuildContext context, int index) {
    ref.read(selectedSystemIndexProvider.state).state = index;
    Navigate.to(
      (context) => const GameListScreen(),
      direction: Axis.vertical,
    );
  }
}

class SystemItemTile extends StatelessWidget {
  const SystemItemTile({
    Key? key,
    required this.system,
    required this.onTap,
    this.selected = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final System system;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform:
          selected ? Matrix4.identity() : (Matrix4.identity()..scale(0.75)),
      transformAlignment: Alignment.bottomCenter,
      duration: defaultAnimationDuration,
      curve: defaultAnimationCurve,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          child: InkWell(
            onTap: onTap,
            child:
                Image.file(services<MediaManager>().getSystemImageFile(system)),
          ),
        ),
      ),
    );
  }
}

class GameSystemDetail extends ConsumerWidget {
  const GameSystemDetail({
    Key? key,
    required this.system,
  }) : super(key: key);

  final System system;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final gameList = ref.watch(gameLibraryProvider(system));
    return Container(
      width: 600,
      margin: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  system.producer,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.end,
                ),
                Text(
                  system.name,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.end,
                ),
                // const SizedBox(height: 8),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: VerticalDivider(
              color: Colors.white38,
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SmallLabel(
                text: gameList.when(
                  data: (data) => Text('${data.length} games'),
                  error: (error, stack) => const SizedBox(),
                  loading: () => const LoadingSpinner.small(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
