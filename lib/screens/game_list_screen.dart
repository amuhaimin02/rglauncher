import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/widgets/fading_edge.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';
import 'package:rglauncher/widgets/loading_spinner.dart';
import 'package:rglauncher/widgets/small_label.dart';

import '../data/configs.dart';
import '../data/providers.dart';
import '../features/app_launcher.dart';
import '../features/services.dart';
import '../utils/navigate.dart';
import '../widgets/command.dart';
import '../widgets/gamepad_listener.dart';
import '../widgets/image_with_status.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannedSystems = ref.watch(scannedSystemProvider);
    return scannedSystems.when(
      error: (error, stack) => Text('$error\n$stack'),
      loading: () => const CircularProgressIndicator(),
      data: (systems) {
        return LauncherScaffold(
          // backgroundImage: FileImage(
          //   services<MediaManager>().getGameMediaFile(game),
          // ),
          // body: PageView.builder(
          //   controller: _pageController,
          //   itemCount: systems.length,
          //   itemBuilder: (context, index) {
          //     final system = systems[index];
          //     return GameListContent(
          //       titles: system.name,
          //       gameLists: library[system]!,
          //     );
          //   },
          //   onPageChanged: (newIndex) {
          //     ref.read(selectedSystemIndexProvider.state).state = newIndex;
          //     ref.read(selectedGameListIndexProvider.state).state = 0;
          //   },
          // ),
          body: GameListContent(
            pageSize: systems.length,
            getTitle: (index) => systems[index].name,
            getGameList: (index) =>
                ref.watch(gameLibraryProvider(systems[index]).future),
            onPageChanged: (newIndex) {
              Future.microtask(() {
                ref.read(selectedSystemIndexProvider.state).state = newIndex;
                ref.read(selectedGameListIndexProvider.state).state = 0;
              });
            },
          ),
        );
      },
    );
  }
}

class SingleGameListScreen extends StatelessWidget {
  const SingleGameListScreen(
      {Key? key, required this.title, required this.gameList})
      : super(key: key);

  final String title;
  final List<Game> gameList;

  @override
  Widget build(BuildContext context) {
    return GameListContent(
      pageSize: 1,
      getTitle: (_) => title,
      getGameList: (_) async => gameList,
    );
  }
}

class FavoritedGameListScreen extends ConsumerWidget {
  const FavoritedGameListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritedGames = ref.watch(favoritedGamesProvider);
    return favoritedGames.when(
      data: (list) => SingleGameListScreen(title: 'Favorite', gameList: list),
      error: (e, s) => Text(e.toString()),
      loading: () => const LoadingSpinner(),
    );
  }
}

class WishlistedGamesListScreen extends ConsumerWidget {
  const WishlistedGamesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistedGames = ref.watch(wishlistedGamesProvider);
    return wishlistedGames.when(
      data: (list) => SingleGameListScreen(title: 'Wishlist', gameList: list),
      error: (e, s) => Text(e.toString()),
      loading: () => const LoadingSpinner(),
    );
  }
}

class RecentGameListScreen extends ConsumerWidget {
  const RecentGameListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentGames = ref.watch(recentGamesProvider);
    return recentGames.when(
      data: (list) => SingleGameListScreen(title: 'Recent', gameList: list),
      error: (e, s) => Text(e.toString()),
      loading: () => const LoadingSpinner(),
    );
  }
}

class NewlyAddedListScreen extends ConsumerWidget {
  const NewlyAddedListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newGames = ref.watch(newlyAddedGamesProvider);
    return newGames.when(
      data: (list) =>
          SingleGameListScreen(title: 'Newly added', gameList: list),
      error: (e, s) => Text(e.toString()),
      loading: () => const LoadingSpinner(),
    );
  }
}

// class GameBackground extends ConsumerWidget {
//   const GameBackground({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedGameIndex = ref.watch(selectedGameListIndexProvider);
//     return Image.network(
//       'https://picsum.photos/id/$selectedGameIndex/1280/720',
//       fit: BoxFit.cover,
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       opacity: const AlwaysStoppedAnimation(0.2),
//     );
//   }
// }

class GameListContent extends ConsumerStatefulWidget {
  const GameListContent({
    Key? key,
    required this.pageSize,
    required this.getTitle,
    required this.getGameList,
    this.onPageChanged,
  })  : paginated = pageSize > 1,
        super(key: key);

  final int pageSize;
  final String Function(int index) getTitle;
  final Future<List<Game>> Function(int index) getGameList;
  final Function(int index)? onPageChanged;
  final bool paginated;

  @override
  ConsumerState<GameListContent> createState() => _GameListContentState();
}

class _GameListContentState extends ConsumerState<GameListContent> {
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
    if (widget.paginated) {
      ref.listen(selectedSystemIndexProvider, (prevIndex, newIndex) {
        _pageController.animateToPage(
          newIndex,
          duration: defaultAnimationDuration,
          curve: defaultAnimationCurve,
        );
      });
    }

    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: FadingEdge(
            direction: Axis.horizontal,
            fadingEdgeSize: 8,
            child: PageView.builder(
              controller: widget.paginated ? _pageController : null,
              itemCount: widget.pageSize,
              itemBuilder: (context, index) {
                return FutureBuilder<List<Game>>(
                    future: widget.getGameList(index),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0) -
                                const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Text(
                                  widget.getTitle(index),
                                  style: textTheme.headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                if (snapshot.data != null)
                                  SmallLabel(
                                    text:
                                        Text(snapshot.data!.length.toString()),
                                  )
                              ],
                            ),
                          ),
                          Expanded(child: () {
                            if (snapshot.data != null) {
                              return GameListView(
                                gameList: snapshot.data!,
                              );
                            } else {
                              return const LoadingSpinner();
                            }
                          }()),
                        ],
                      );
                    });
              },
              onPageChanged: widget.onPageChanged,
            ),
          ),
        ),
        const Expanded(
          flex: 5,
          child: GameDetailPane(),
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
    final selectedGame = ref.watch(selectedGameProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: AnimatedSize(
          duration: defaultAnimationDuration,
          curve: defaultAnimationCurve,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 240,
              minHeight: 240,
            ),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              color: Colors.grey.shade800,
              child: selectedGame.when(
                data: (game) {
                  if (game != null) {
                    return ImageWithStatus(
                      image: FileImage(
                        services<MediaManager>().getGameMediaFile(game),
                      ),
                    );
                  } else {
                    return Container(
                      width: 240,
                      height: 230,
                      alignment: Alignment.center,
                      child: const Text('No game'),
                    );
                  }
                },
                error: (error, stack) {
                  return Container(
                    width: 240,
                    height: 230,
                    alignment: Alignment.center,
                    child: const Text('Error'),
                  );
                },
                loading: () => const SizedBox(
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
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

  final List<Game> gameList;

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

    return CommandWrapper(
      commands: [
        Command(button: CommandButton.x, label: 'Options', onTap: () {}),
        Command(
          button: CommandButton.a,
          label: 'Open',
          onTap: () => _onItemSelected(context),
        ),
        Command(
          button: CommandButton.b,
          label: 'Back',
          onTap: () => Navigate.back(),
        ),
      ],
      child: GamepadListener(
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
        onA: () {
          _onItemSelected(context);
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
              return FadingEdge(
                direction: Axis.vertical,
                fadingEdgeSize: 100,
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.gameList[index].name,
                                  style: textTheme.bodyLarge!.copyWith(
                                    color: index == _currentIndex
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.gameList[index].isFavorite)
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                            ],
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
      ),
    );
  }

  void _onListTap(BuildContext context, int index) {
    final currentIndex = ref.read(selectedGameListIndexProvider);
    if (currentIndex == index) {
      _onItemSelected(context);
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

  void _onItemSelected(BuildContext context) async {
    final game = widget.gameList[_currentIndex];
    final emulators =
        await ref.read(systemEmulatorsProvider(game.systemCode).future);
    services<AppLauncher>().launchGameUsingEmulator(
      game,
      emulators.first,
    );
  }
}
