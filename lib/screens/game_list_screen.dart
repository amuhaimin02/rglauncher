import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/utils/range_limiting.dart';
import 'package:rglauncher/widgets/small_label.dart';

import '../data/configs.dart';
import '../data/providers.dart';
import '../widgets/command.dart';
import '../widgets/custom_page_view.dart';
import '../widgets/gamepad_listener.dart';

class GameListScreen extends ConsumerStatefulWidget {
  const GameListScreen({super.key});

  @override
  ConsumerState<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends ConsumerState<GameListScreen> {
  late final PageController _pageController = PageController(
    initialPage: ref.watch(selectedSystemIndexProvider),
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSystems = ref.watch(allSystemsProvider);
    ref.listen(selectedSystemIndexProvider, (prevIndex, newIndex) {
      _pageController.animateToPage(
        newIndex,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });
    return CommandWrapper(
      commands: [
        Command(button: CommandButton.x, label: 'Options', onTap: () {}),
        Command(button: CommandButton.a, label: 'Open', onTap: () {}),
        Command(
          button: CommandButton.b,
          label: 'Back',
          onTap: () => Navigator.pop(context),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            const GameBackground(),
            CustomPageView.builder(
              controller: _pageController,
              itemCount: allSystems.length,
              itemBuilder: (context, index) {
                return GameListContent(
                  title: allSystems[index].name,
                  gameList: List.generate(
                      50, (index) => 'Street Fighter ${index + 1}th Edition'),
                );
              },
              onPageChanged: (newIndex) {
                ref.read(selectedSystemIndexProvider.state).state = newIndex;
                ref.read(selectedGameListIndexProvider.state).state = 0;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SingleGameListScreen extends StatelessWidget {
  const SingleGameListScreen(
      {Key? key, required this.title, required this.gameList})
      : super(key: key);

  final String title;
  final List<String> gameList;

  @override
  Widget build(BuildContext context) {
    return CommandWrapper(
      commands: [
        Command(button: CommandButton.x, label: 'Options', onTap: () {}),
        Command(button: CommandButton.a, label: 'Open', onTap: () {}),
        Command(
          button: CommandButton.b,
          label: 'Back',
          onTap: () => Navigator.pop(context),
        ),
      ],
      child: GameListContent(
        title: title,
        gameList: gameList,
      ),
    );
  }
}

class GameBackground extends ConsumerWidget {
  const GameBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGameIndex = ref.watch(selectedGameListIndexProvider);
    return Image.network(
      'https://picsum.photos/id/$selectedGameIndex/1280/720',
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      opacity: const AlwaysStoppedAnimation(0.2),
    );
  }
}

class GameListContent extends ConsumerWidget {
  const GameListContent({Key? key, required this.title, required this.gameList})
      : super(key: key);

  final String title;
  final List<String> gameList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.all(20.0) - const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Text(
                title,
                style: textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              SmallLabel(
                text: Text(gameList.length.toString()),
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GameListView(
                  gameList: gameList,
                ),
              ),
              const Expanded(
                child: GameDetailPane(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GameDetailPane extends ConsumerWidget {
  const GameDetailPane({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final selectedGameIndex = ref.watch(selectedGameListIndexProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://picsum.photos/id/$selectedGameIndex/640/640',
              ),
            ),
            const SizedBox(height: 8),
            Text('Game $selectedGameIndex', style: textTheme.titleLarge),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class GameListView extends ConsumerStatefulWidget {
  const GameListView({
    Key? key,
    required this.gameList,
  }) : super(key: key);

  final List<String> gameList;

  @override
  ConsumerState<GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends ConsumerState<GameListView> {
  final _scrollController = ScrollController();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    ref.listen(selectedGameListIndexProvider, (prevIndex, newIndex) {
      _scrollController.animateTo(
        newIndex * gameListItemHeight,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });

    return GamepadListener(
      key: const ValueKey('gamelist'),
      onDirectional: (direction, repeating) {
        switch (direction) {
          case GamepadDirection.up:
            if (repeating) {
              _softSetIndex(_currentIndex - 1, animate: true);
            } else {
              _hardSetIndex(_currentIndex - 1);
            }
            break;
          case GamepadDirection.down:
            if (repeating) {
              _softSetIndex(_currentIndex + 1, animate: true);
            } else {
              _hardSetIndex(_currentIndex + 1);
            }
            break;
          case GamepadDirection.left:
            if (repeating) return;
            ref.read(selectedSystemIndexProvider.state).state--;
            break;
          case GamepadDirection.right:
            if (repeating) return;
            ref.read(selectedSystemIndexProvider.state).state++;
            break;
        }
      },
      onLeftShoulder: () {
        _hardSetIndex(_currentIndex - 10);
      },
      onRightShoulder: () {
        _hardSetIndex(_currentIndex + 10);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo is ScrollUpdateNotification) {
            final computedIndex =
                (scrollInfo.metrics.pixels / gameListItemHeight).round();
            _softSetIndex(computedIndex);
            return true;
          } else if (scrollInfo is UserScrollNotification) {
            final computedIndex =
                (scrollInfo.metrics.pixels / gameListItemHeight).round();
            _hardSetIndex(computedIndex);
            return true;
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widgetHeight = constraints.maxHeight;
            return ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent
                  ],
                  stops: [0, 0.2, 0.8, 1],
                ).createShader(
                  Rect.fromLTRB(0, 0, rect.width, rect.height),
                );
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0) +
                    EdgeInsets.symmetric(vertical: widgetHeight / 2.5),
                controller: _scrollController,
                itemCount: widget.gameList.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _onListTap(context, index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: AlignmentDirectional.centerStart,
                        height: gameListItemHeight,
                        child: Text(
                          widget.gameList[index],
                          style: textTheme.bodyLarge!.copyWith(
                            color: index == _currentIndex
                                ? Colors.black
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _onListTap(BuildContext context, int index) {
    final currentIndex = ref.read(selectedGameListIndexProvider);
    if (currentIndex == index) {
    } else {
      ref.read(selectedGameListIndexProvider.state).state = index;
    }
  }

  void _hardSetIndex(int newIndex) {
    newIndex = newIndex.clamp(0, widget.gameList.length - 1);
    ref.read(selectedGameListIndexProvider.state).state = newIndex;
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _softSetIndex(int newIndex, {bool animate = false}) {
    if (_currentIndex == newIndex) return;
    newIndex = newIndex.clamp(0, widget.gameList.length - 1);

    if (animate) {
      _scrollController.jumpTo(
        newIndex * gameListItemHeight,
        // duration: Duration(milliseconds: 100),
        // curve: defaultAnimationCurve,
      );
    }
    setState(() {
      _currentIndex = newIndex;
    });
  }
}
