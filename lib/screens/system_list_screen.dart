import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/providers.dart';
import 'package:rglauncher/screens/game_list_screen.dart';

import '../configs.dart';
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
            if (direction == GamepadDirection.left) {
              ref.read(selectedSystemIndexProvider.state).state--;
            } else if (direction == GamepadDirection.right) {
              ref.read(selectedSystemIndexProvider.state).state++;
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
    final currentSystem = ref.watch(selectedSystemProvider);
    final textTheme = Theme.of(context).textTheme;
    ref.listen(selectedSystemIndexProvider, (prevIndex, newIndex) {
      _pageController.animateToPage(
        newIndex,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });
    return Column(
      children: [
        const Spacer(flex: 1),
        Expanded(
          flex: 4,
          child: Center(
            child: Text(currentSystem, style: textTheme.headlineSmall),
          ),
        ),
        Expanded(
          flex: 8,
          child: PageView(
            controller: _pageController,
            children: [
              for (int i = 0; i < systemList.length; i++)
                InkWell(
                  onTap: () => _openGameListScreen(context, i),
                  child: AnimatedContainer(
                    transform: currentSystemIndex == i
                        ? Matrix4.identity()
                        : (Matrix4.identity()..scale(0.8)),
                    transformAlignment: Alignment.center,
                    // padding: currentSystemIndex == i
                    //     ? EdgeInsets.zero
                    //     : const EdgeInsets.all(16),
                    duration: defaultAnimationDuration,
                    curve: defaultAnimationCurve,
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.white38,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child:
                            Image.network('https://picsum.photos/320/320?r=$i'),
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
        const Spacer(flex: 3)
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
