import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rglauncher/data/models.dart';
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/widgets/async_widget.dart';
import 'package:rglauncher/widgets/clicky_list_view.dart';
import 'package:rglauncher/widgets/fading_edge.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';
import 'package:rglauncher/widgets/loading_spinner.dart';
import 'package:rglauncher/widgets/menu_options_dialog.dart';
import 'package:rglauncher/widgets/small_label.dart';

import '../data/configs.dart';
import '../data/database.dart';
import '../data/providers.dart';
import '../features/app_launcher.dart';
import '../features/notification_manager.dart';
import '../features/services.dart';
import '../utils/navigate.dart';
import '../widgets/command.dart';
import '../widgets/gamepad_listener.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGame = ref.watch(selectedGameProvider);
    return LauncherScaffold(
      backgroundImage: selectedGame != null
          ? FileImage(
              services<MediaManager>().getGameScreenshotFile(selectedGame),
            )
          : null,
      body: AsyncWidget(
        value: ref.watch(scannedSystemProvider),
        data: (systems) {
          return GameListContent(
            pageSize: systems.length,
            initialIndex: () {
              final selectedSystem = ref.read(selectedSystemProvider);
              if (selectedSystem != null) {
                return systems.indexOf(selectedSystem);
              } else {
                return 0;
              }
            }(),
            getTitle: (index) => systems[index].name,
            getGameList: (index) =>
                ref.watch(gameLibraryProvider(systems[index]).future),
            onPageChanged: (index) {
              Future.microtask(() {
                ref.read(selectedSystemProvider.state).state = systems[index];
              });
            },
          );
        },
      ),
    );
  }
}

class SingleGameListScreen extends ConsumerWidget {
  const SingleGameListScreen(
      {Key? key, required this.title, required this.gameList})
      : super(key: key);

  final String title;
  final List<Game> gameList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGame = ref.watch(selectedGameProvider);
    return LauncherScaffold(
      backgroundImage: selectedGame != null
          ? FileImage(
              services<MediaManager>().getGameBoxArtFile(selectedGame),
            )
          : null,
      body: GameListContent(
        pageSize: 1,
        getTitle: (_) => title,
        getGameList: (_) async => gameList,
      ),
    );
  }
}

class FavoritedGameListScreen extends ConsumerWidget {
  const FavoritedGameListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncWidget(
      value: ref.watch(favoritedGamesProvider),
      data: (list) => SingleGameListScreen(title: 'Favorite', gameList: list),
    );
  }
}

class WishlistedGamesListScreen extends ConsumerWidget {
  const WishlistedGamesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncWidget(
      value: ref.watch(wishlistedGamesProvider),
      data: (list) => SingleGameListScreen(title: 'Wishlist', gameList: list),
    );
  }
}

class RecentGameListScreen extends ConsumerWidget {
  const RecentGameListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncWidget(
      value: ref.watch(recentGamesProvider),
      data: (list) => SingleGameListScreen(title: 'Recent', gameList: list),
    );
  }
}

class NewlyAddedListScreen extends ConsumerWidget {
  const NewlyAddedListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncWidget(
      value: ref.watch(newlyAddedGamesProvider),
      data: (list) =>
          SingleGameListScreen(title: 'Newly added', gameList: list),
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
    this.initialIndex,
    this.onPageChanged,
  })  : paginated = pageSize > 1,
        super(key: key);

  final int pageSize;
  final int? initialIndex;
  final String Function(int index) getTitle;
  final Future<List<Game>> Function(int index) getGameList;
  final Function(int index)? onPageChanged;
  final bool paginated;

  @override
  ConsumerState<GameListContent> createState() => _GameListContentState();
}

class _GameListContentState extends ConsumerState<GameListContent> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex ?? 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 1;
        if (details.delta.dx > sensitivity) {
          _pageController.previousPage(
            duration: defaultAnimationDuration,
            curve: defaultAnimationCurve,
          );
        } else if (details.delta.dx < -sensitivity) {
          _pageController.nextPage(
            duration: defaultAnimationDuration,
            curve: defaultAnimationCurve,
          );
        }
      },
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: FadingEdge(
              direction: Axis.horizontal,
              fadingEdgeSize: 8,
              child: PageView.builder(
                controller: widget.paginated ? _pageController : null,
                physics: const NeverScrollableScrollPhysics(),
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
                                showSystemCode: !widget.paginated,
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
      ),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSwitcher(
              duration: defaultAnimationDuration,
              switchInCurve:
                  const Interval(0.5, 1, curve: defaultAnimationCurve),
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                // if (animation.status == AnimationStatus.dismissed) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                  child: RotationTransition(
                    turns:
                        Tween<double>(begin: 0.99, end: 1).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
                // } else {
                //   return ScaleTransition(
                //     scale: Tween<double>(begin: 0.7, end: 1).animate(animation),
                //     child: FadeTransition(
                //       opacity: animation,
                //       child: child,
                //     ),
                //   );
                // }
              },
              child: Material(
                key: ObjectKey(game),
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                color: Colors.grey.shade800,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 120,
                    minHeight: 120,
                  ),
                  child: () {
                    if (game == null) {
                      return Container(
                        width: 240,
                        height: 240,
                        alignment: Alignment.center,
                        child: const Text('No game selected'),
                      );
                    }
                    final imageFile =
                        services<MediaManager>().getGameBoxArtFile(game);
                    if (imageFile.existsSync()) {
                      return Image(
                        image: FileImage(
                          services<MediaManager>().getGameBoxArtFile(game),
                        ),
                      );
                    } else {
                      return Container(
                        width: 240,
                        height: 240,
                        alignment: Alignment.center,
                        child: const Text('No media'),
                      );
                    }
                  }(),
                ),
              ),
            )
            // FutureWidget(
            //   future: ref.watch(selectedGameMetadataProvider.future),
            //   builder: (context, meta) {
            //     final textTheme = Theme.of(context).textTheme;
            //     return Padding(

            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.end,
            //         children: [
            //           Text(meta?.title ?? 'No title',
            //               style: textTheme.headlineSmall),
            //           Text(meta?.description ?? 'No meta',
            //               style: textTheme.bodyMedium),
            //           const SizedBox(height: 8),
            //           Text(meta?.genre ?? 'No genre',
            //               style: textTheme.bodySmall),
            //         ],
            //       ),
            //     );
            //   },
            // ),
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
    this.showSystemCode = true,
  }) : super(key: key);

  final List<Game> gameList;
  final bool showSystemCode;

  @override
  ConsumerState<GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends ConsumerState<GameListView> {
  final _controller = ClickyListScrollController();

  @override
  Widget build(BuildContext context) {
    return CommandWrapper(
      commands: [
        Command(
          button: CommandButton.x,
          label: 'Options',
          onTap: () async {
            final game = ref.read(selectedGameProvider);
            if (game != null) {
              showMenuOptions(
                context: context,
                title: game.name,
                options: [
                  MenuOption(
                    title: 'View game details',
                    icon: const Icon(Icons.info),
                    onTap: () async {},
                  ),
                  MenuOption(
                    title: !game.isFavorite
                        ? 'Add to favorites'
                        : 'Remove from favorites',
                    icon: !game.isFavorite
                        ? const Icon(MdiIcons.heart)
                        : const Icon(MdiIcons.heartOff),
                    onTap: () => _toggleFavorite(game),
                  ),
                  MenuOption(
                    title: !game.isWishlist
                        ? 'Add to wishlist'
                        : 'Remove from wishlist',
                    icon: !game.isWishlist
                        ? const Icon(MdiIcons.bookmark)
                        : const Icon(MdiIcons.bookmarkOff),
                    onTap: () => _toggleWishlist(game),
                  ),
                  MenuOption(
                    title: !game.isPinned ? 'Pin game' : 'Unpin game',
                    icon: !game.isPinned
                        ? const Icon(MdiIcons.pin)
                        : const Icon(MdiIcons.pinOff),
                    onTap: () => _togglePin(game),
                  ),
                  MenuOption(
                    title: 'Change this game\'s settings',
                    icon: const Icon(Icons.games),
                    onTap: () async {},
                  ),
                  MenuOption(
                    title: 'Change systems settings',
                    icon: const Icon(Icons.videogame_asset_rounded),
                    onTap: () async {},
                  ),
                ],
              );
            }
          },
        ),
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
                showSystemCode: widget.showSystemCode,
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

  Future<void> _toggleFavorite(Game game) async {
    final db = services<Database>();
    final notifier = ref.read(notificationProvider.notifier);

    final added = await db.toggleFavorite(game);
    if (added) {
      notifier.set(
        const NotificationMessage(
          label: 'Added to favorites',
          status: NotificationStatus.success,
          icon: Icon(Icons.favorite_rounded),
        ),
      );
    } else {
      notifier.set(
        const NotificationMessage(
          label: 'Removed from favorites',
          status: NotificationStatus.success,
          icon: Icon(Icons.favorite_outline_rounded),
        ),
      );
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _toggleWishlist(Game game) async {
    final db = services<Database>();
    final notifier = ref.read(notificationProvider.notifier);

    final added = await db.toggleWishlist(game);
    if (added) {
      notifier.set(
        const NotificationMessage(
          label: 'Added to wishlist',
          status: NotificationStatus.success,
          icon: Icon(Icons.bookmark_rounded),
        ),
      );
    } else {
      notifier.set(
        const NotificationMessage(
          label: 'Removed from wishlist',
          status: NotificationStatus.success,
          icon: Icon(Icons.bookmark_outline_rounded),
        ),
      );
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _togglePin(Game game) async {
    final db = services<Database>();
    final notifier = ref.read(notificationProvider.notifier);

    final added = await db.togglePinGame(game, 0);
    if (added) {
      notifier.set(
        const NotificationMessage(
          label: 'Pinned game to home page',
          status: NotificationStatus.success,
          icon: Icon(MdiIcons.pin),
        ),
      );
    } else {
      notifier.set(
        const NotificationMessage(
          label: 'Unpinned from home page',
          status: NotificationStatus.success,
          icon: Icon(MdiIcons.pinOff),
        ),
      );
    }
    HapticFeedback.mediumImpact();
  }
}

class GameListTile extends StatelessWidget {
  const GameListTile({
    Key? key,
    required this.onTap,
    required this.game,
    this.selected = false,
    this.showSystemCode = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final Game game;
  final bool selected;
  final bool showSystemCode;

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
              if (game.isFavorite) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
              ],
              if (game.isWishlist) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.bookmark,
                  color: Colors.amber,
                )
              ],
              if (game.isPinned) ...[
                const SizedBox(width: 4),
                const Icon(
                  MdiIcons.pin,
                  color: Colors.grey,
                )
              ],
              if (showSystemCode) ...[
                const SizedBox(width: 8),
                SmallLabel(
                  backgroundColor: Colors.grey.withOpacity(0.7),
                  textColor: Colors.white,
                  text: Text(game.systemCode),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
