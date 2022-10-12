import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/widgets/clicky_list_view.dart';
import 'package:rglauncher/widgets/fading_edge.dart';
import 'package:rglauncher/widgets/future_widget.dart';
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
              // Future.microtask(() {
              //   ref.read(selectedSystemIndexProvider.state).state = newIndex;
              // });
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
  late final PageController _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.paginated) {
      // Future.microtask(() {
      //   _pageController.jumpToPage(ref.read(selectedSystemIndexProvider));
      // });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.paginated) {
    //   ref.listen(selectedSystemProvider, (prevIndex, newIndex) {
    //     _pageController.animateToPage(
    //       newIndex,
    //       duration: defaultAnimationDuration,
    //       curve: defaultAnimationCurve,
    //     );
    //   });
    // }

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
                                  text: Text(snapshot.data!.length.toString()),
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
                  },
                );
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
    final game = ref.watch(selectedGameProvider);
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  game != null
                      ? Image(
                          image: FileImage(
                            services<MediaManager>().getGameMediaFile(game),
                          ),
                        )
                      : Container(
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          child: const Text('No game'),
                        ),
                  FutureWidget(
                    future: ref.watch(selectedGameMetadataProvider.future),
                    builder: (context, meta) {
                      final textTheme = Theme.of(context).textTheme;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(meta?.title ?? 'No title',
                                style: textTheme.headlineSmall),
                            Text(meta?.description ?? 'No meta',
                                style: textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(meta?.genre ?? 'No genre',
                                style: textTheme.bodySmall),
                          ],
                        ),
                      );
                    },
                  ),
                ],
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
  final _controller = ClickyListScrollController();

  @override
  Widget build(BuildContext context) {
    return CommandWrapper(
      commands: [
        Command(button: CommandButton.x, label: 'Options', onTap: () {}),
        Command(
          button: CommandButton.a,
          label: 'Open',
          onTap: () => _onItemSelected(context, _controller.currentIndex),
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
                _controller.goPreviousBy(1, fast: true);
              } else {
                _controller.goPreviousBy(1);
              }
              break;
            case GamepadDirection.down:
              if (repeating) {
                _controller.goNextBy(1, fast: true);
              } else {
                _controller.goNextBy(1);
              }
              break;
            case GamepadDirection.left:
              if (repeating) return;
              // ref.read(selectedSystemIndexProvider.state).state--;
              break;
            case GamepadDirection.right:
              if (repeating) return;
              // ref.read(selectedSystemIndexProvider.state).state++;
              break;
          }
        },
        onLeftShoulder: () {
          _controller.goPreviousBy(10);
        },
        onRightShoulder: () {
          _controller.goNextBy(10);
        },
        onA: () {
          _onItemSelected(context, _controller.currentIndex);
        },
        child: FadingEdge(
          direction: Axis.vertical,
          fadingEdgeSize: 48,
          child: ClickyListView(
            controller: _controller,
            sideGap: 12,
            listItemSize: gameListItemHeight,
            itemCount: widget.gameList.length,
            itemBuilder: (context, index, selected) {
              return GameListTile(
                onTap: () => _onListTap(context, index),
                selected: selected,
                game: widget.gameList[index],
              );
            },
            onChanged: (index) {
              ref.read(selectedGameProvider.state).state =
                  widget.gameList[index];
              // ref.read(selectedGameListIndexProvider.state).state = index;
            },
            onListEmpty: () {
              ref.read(selectedGameProvider.state).state = null;
            },
          ),
        ),
      ),
    );
  }

  void _onListTap(BuildContext context, int index) {
    final currentIndex = _controller.currentIndex;
    if (currentIndex == index) {
      _onItemSelected(context, index);
    } else {
      _controller.jumpToIndex(index);
    }
  }

  void _onItemSelected(BuildContext context, int index) async {
    final game = widget.gameList[index];
    final emulators =
        await ref.read(systemEmulatorsProvider(game.systemCode).future);
    services<AppLauncher>().launchGameUsingEmulator(
      game,
      emulators.first,
    );
  }
}

class GameListTile extends StatelessWidget {
  const GameListTile({
    Key? key,
    required this.onTap,
    required this.game,
    this.selected = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final Game game;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: AlignmentDirectional.centerStart,
          height: gameListItemHeight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  game.name,
                  style: textTheme.bodyLarge!.copyWith(
                    color: selected ? Colors.black : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (game.isFavorite)
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
            ],
          ),
        ),
      ),
    );
  }
}
