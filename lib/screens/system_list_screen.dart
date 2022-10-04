import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/screens/game_list_screen.dart';
import 'package:rglauncher/utils/range_limiting.dart';
import 'package:rglauncher/widgets/small_label.dart';

import '../data/configs.dart';
import '../widgets/command.dart';
import '../widgets/gamepad_listener.dart';
import '../widgets/sliding_transition_page_route.dart';

class SystemListScreen extends ConsumerWidget {
  const SystemListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommandWrapper(
      commands: [
        Command(
          button: CommandButton.a,
          label: 'Open',
          onTap: () => _openGameListScreen(context),
        ),
        Command(
          button: CommandButton.b,
          label: 'Back',
          onTap: () => Navigator.pop(context),
        ),
      ],
      child: Scaffold(
        body: GamepadListener(
          key: const ValueKey('system'),
          onDirectional: (direction, repeating) {
            int itemSize = ref.read(allSystemsProvider).length;
            if (direction == GamepadDirection.left) {
              rangeLimit(
                value: ref.read(selectedSystemIndexProvider) - 1,
                max: itemSize,
                ifInRange: () =>
                    ref.read(selectedSystemIndexProvider.state).state--,
              );
            } else if (direction == GamepadDirection.right) {
              rangeLimit(
                value: ref.read(selectedSystemIndexProvider) + 1,
                max: itemSize,
                ifInRange: () =>
                    ref.read(selectedSystemIndexProvider.state).state++,
              );
            }
          },
          onA: () => _openGameListScreen(context),
          child: const SystemPageView(),
        ),
      ),
    );
  }

  void _openGameListScreen(BuildContext context) {
    Navigator.push(
      context,
      SlidingTransitionPageRoute(
        builder: (context) => const GameListScreen(),
        direction: Axis.vertical,
      ),
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
    final systemList = ref.watch(allSystemsProvider);
    final currentSystemIndex = ref.watch(selectedSystemIndexProvider);
    ref.listen(selectedSystemIndexProvider, (prevIndex, newIndex) {
      _pageController.animateToPage(
        newIndex,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });
    return Column(
      children: [
        const Expanded(
          flex: 6,
          child: GameSystemDetail(),
        ),
        Expanded(
          flex: 6,
          child: PageView(
            controller: _pageController,
            children: [
              for (int i = 0; i < systemList.length; i++)
                InkWell(
                  onTap: () => _openGameListScreen(context, i),
                  child: AnimatedContainer(
                    transform: currentSystemIndex == i
                        ? Matrix4.identity()
                        : (Matrix4.identity()..scale(0.75)),
                    transformAlignment: Alignment.bottomCenter,
                    // padding: currentSystemIndex == i
                    //     ? EdgeInsets.zero
                    //     : const EdgeInsets.all(16),
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
                        child: Image.network(
                          systemList[i].imageLink,
                        ),
                      ),
                    ),
                  ),
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
  }

  void _openGameListScreen(BuildContext context, int index) {
    ref.read(selectedSystemIndexProvider.state).state = index;
    Navigator.push(
      context,
      SlidingTransitionPageRoute(
        builder: (context) => const GameListScreen(),
        direction: Axis.vertical,
      ),
    );
  }
}

class GameSystemDetail extends ConsumerWidget {
  const GameSystemDetail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final system = ref.watch(selectedSystemProvider);
    final textTheme = Theme.of(context).textTheme;
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
                Text(system.producer, style: textTheme.titleMedium),
                Text(system.name, style: textTheme.headlineMedium),
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
          const Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SmallLabel(
                text: Text('50 games'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
