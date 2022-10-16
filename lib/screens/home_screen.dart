import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/features/library_manager.dart';
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/features/services.dart';
import 'package:rglauncher/screens/all_apps_screen.dart';
import 'package:rglauncher/screens/system_list_screen.dart';
import 'package:rglauncher/utils/extensions.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/gamepad_listener.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';
import 'package:rglauncher/widgets/two_line_grid_view.dart';

import '../features/app_launcher.dart';
import '../utils/navigate.dart';
import '../widgets/large_clock.dart';
import '../widgets/menu_dialog.dart';
import '../widgets/shadowed_text.dart';
import 'game_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LauncherScaffold(
      body: HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<TwoLineItemType> _itemTypes;
  late Function(int index) _itemLauncher;

  @override
  Widget build(BuildContext context) {
    final pinnedApps = ref.watch(pinnedAppsProvider);
    final pinnedGames = ref.watch(pinnedGamesProvider);
    final continueGame = ref.watch(continueGameProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: CommandWrapper(
        commands: [
          Command(
            button: CommandButton.x,
            label: 'Options',
            onTap: () => _openMenuOptions(),
          ),
          Command(
            button: CommandButton.a,
            label: 'Open',
            onTap: () => _onButtonAPressed(context),
          ),
        ],
        child: GamepadListener(
          key: const ValueKey('home'),
          onDirectional: (direction, repeating) {
            final currentIndex = ref.read(selectedMenuIndexProvider);

            switch (direction) {
              case GamepadDirection.up:
                _goToMenuIndex(currentIndex - 1);
                break;
              case GamepadDirection.down:
                _goToMenuIndex(currentIndex + 1);
                break;
              case GamepadDirection.left:
                if ((_itemTypes[currentIndex] == TwoLineItemType.top &&
                        _itemTypes.get(currentIndex - 1) ==
                            TwoLineItemType.bottom) ||
                    (_itemTypes[currentIndex] == TwoLineItemType.bottom &&
                        _itemTypes.get(currentIndex - 1) ==
                            TwoLineItemType.top)) {
                  _goToMenuIndex(currentIndex - 2);
                } else {
                  _goToMenuIndex(currentIndex - 1);
                }
                break;
              case GamepadDirection.right:
                if ((_itemTypes[currentIndex] == TwoLineItemType.top &&
                        _itemTypes.get(currentIndex + 1) ==
                            TwoLineItemType.bottom) ||
                    (_itemTypes[currentIndex] == TwoLineItemType.bottom &&
                        _itemTypes.get(currentIndex + 1) ==
                            TwoLineItemType.top)) {
                  _goToMenuIndex(currentIndex + 2);
                } else {
                  _goToMenuIndex(currentIndex + 1);
                }
                break;
            }
          },
          onA: () => _onButtonAPressed(context),
          onB: () {},
          child: TwoLineGridView(
            padding: const EdgeInsets.all(64),
            childPadding: const EdgeInsets.all(8),
            onItemArranged: (types) => _itemTypes = types,
            itemLauncherCallback: (launcher) => _itemLauncher = launcher,
            items: [
              const TwoLineGridItem(
                large: true,
                aspectRatio: 1.2,
                child: LargeClock(),
              ),
              const TwoLineDivider(),
              continueGame.when(
                error: (error, stack) => const TwoLineGridItem(
                  large: true,
                  aspectRatio: 0.6,
                  child: LoadingTile(),
                ),
                loading: () => const TwoLineGridItem(
                  large: true,
                  aspectRatio: 0.6,
                  child: LoadingTile(),
                ),
                data: (game) {
                  return TwoLineGridItem(
                    large: true,
                    aspectRatio: 0.6,
                    child: MenuTile(
                      label: 'Continue',
                      sublabel: game?.name ?? 'No games played',
                      icon: Icons.play_circle_rounded,
                      image: game != null
                          ? FileImage(
                              services<MediaManager>().getGameBoxArtFile(game))
                          : null,
                    ),
                    onTap: () async {
                      if (game != null) {
                        final emulators = await ref.read(
                            systemEmulatorsProvider(game.systemCode).future);
                        services<AppLauncher>().launchGameUsingEmulator(
                          game,
                          emulators.first,
                        );
                      }
                    },
                  );
                },
              ),
              ...pinnedGames.when(
                error: (error, stack) => [],
                loading: () => [
                  const TwoLineGridItem(child: LoadingTile()),
                ],
                data: (gamesList) {
                  return [
                    for (final game in gamesList)
                      TwoLineGridItem(
                        child: MenuTile(
                          image: FileImage(
                              services<MediaManager>().getGameBoxArtFile(game)),
                        ),
                        onTap: () async {
                          final emulators = await ref.read(
                              systemEmulatorsProvider(game.systemCode).future);
                          services<AppLauncher>().launchGameUsingEmulator(
                            game,
                            emulators.first,
                          );
                        },
                      )
                  ];
                },
              ),
              const TwoLineGridItem(
                child: AddMenuTile(),
              ),
              const TwoLineDivider(),
              TwoLineGridItem(
                onTap: () =>
                    Navigate.to((context) => const FavoritedGameListScreen()),
                child: const MenuTile(
                  label: 'Favorites',
                  icon: Icons.favorite_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () =>
                    Navigate.to((context) => const RecentGameListScreen()),
                child: const MenuTile(
                  label: 'Recent',
                  icon: Icons.history_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () =>
                    Navigate.to((context) => const WishlistedGamesListScreen()),
                child: const MenuTile(
                  label: 'Wishlist',
                  icon: Icons.bookmark_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () =>
                    Navigate.to((context) => const NewlyAddedListScreen()),
                child: const MenuTile(
                  label: 'New',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
              TwoLineGridItem(
                aspectRatio: 0.63,
                large: true,
                child: const MenuTile(
                  label: 'All systems',
                  icon: Icons.sports_esports_rounded,
                ),
                onTap: () => _openSystemListScreen(context),
              ),
              const TwoLineDivider(),
              ...pinnedApps.when(
                error: (error, stack) => [],
                loading: () => [
                  const TwoLineGridItem(child: LoadingTile()),
                ],
                data: (appList) {
                  return [
                    for (final app in appList)
                      TwoLineGridItem(
                        child: AppTile(
                          appName: app.appName,
                          icon: app.icon,
                        ),
                        onTap: () {
                          DeviceApps.openApp(app.packageName);
                        },
                      )
                  ];
                },
              ),
              TwoLineGridItem(
                child: const MenuTile(
                  label: 'All apps',
                  icon: Icons.apps_rounded,
                ),
                onTap: () => Navigate.to((context) => const AllAppsScreen()),
              ),
              const TwoLineGridItem(child: AddMenuTile()),
            ],
          ),
        ),
      ),
    );
  }

  void _goToMenuIndex(int newIndex) {
    newIndex = newIndex.clamp(0, _itemTypes.length - 1);
    ref.read(selectedMenuIndexProvider.state).state = newIndex;
  }

  void _openSystemListScreen(BuildContext context) {
    Navigate.to(
      (context) => const SystemListScreen(),
    );
  }

  void _onButtonAPressed(BuildContext context) {
    final selectedIndex = ref.read(selectedMenuIndexProvider);
    _itemLauncher(selectedIndex);
  }

  Future<void> _openMenuOptions() async {
    showMenuDialog(
      context: context,
      options: [
        MenuOption(
          title: 'Refresh game lists',
          icon: const Icon(Icons.refresh),
          onTap: () async {
            final notifier = ref.read(notificationProvider.notifier);
            notifier.runTask(
              initialLabel: 'Scanning game list...',
              failedLabel: 'Scanning failed!',
              successLabel: 'Game list refreshed',
              task: (update) async {
                await services<LibraryManager>().scanLibrariesFromStorage(
                  storagePaths: [Directory('/storage/emulated/0/EmuROM')],
                );
              },
            );
          },
        ),
        MenuOption(
          title: 'Start auto-scraping',
          icon: const Icon(Icons.image),
          onTap: () async {
            final notifier = ref.read(notificationProvider.notifier);
            notifier.runTask(
              initialLabel: 'Scraping...',
              failedLabel: 'Failed scraping!',
              successLabel: 'Scraping completed',
              task: (update) async {
                final allGames = await ref.read(allGamesProvider.future);
                final totalGames = allGames.length;
                await services<LibraryManager>().scrapeAndStoreGameImages(
                  progress: (filename) {
                    update(
                      'Scraping $filename',
                      allGames.indexWhere((e) => e.filename == filename) /
                          totalGames,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class SelectionWrapper extends ConsumerWidget {
  const SelectionWrapper({Key? key, required this.child, required this.index})
      : super(key: key);

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedMenuIndexProvider);
    return Stack(
      children: [
        AnimatedContainer(
          duration: defaultAnimationDuration,
          curve: defaultAnimationCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: selectedIndex == index
                ? Border.all(width: 4, color: Colors.white)
                : null,
          ),
        ),
        child,
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    Key? key,
    this.label,
    this.icon,
    this.image,
    this.sublabel,
  }) : super(key: key);

  final String? label;
  final IconData? icon;
  final ImageProvider? image;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: image != null
            ? const BorderSide(color: Colors.white38, width: 4)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(16),
      ),
      color: image != null ? Colors.black : Colors.white38,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: image != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: image!,
                  opacity: 1,
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: ShadowedText(
          enabled: image != null && (label != null || sublabel != null),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null) ...[
                      Text(label!, style: textTheme.titleLarge),
                    ],
                    if (sublabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sublabel!,
                        style: textTheme.labelLarge,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    icon,
                    size: 56,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.icon,
    required this.appName,
  });

  final Uint8List icon;
  final String appName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appIconImage = MemoryImage(icon);

    return FutureBuilder<PaletteGenerator>(
      future: PaletteGenerator.fromImageProvider(appIconImage),
      builder: (context, snapshot) {
        final palette = snapshot.data?.mutedColor;
        return Material(
          borderRadius: BorderRadius.circular(16),
          color: palette?.color ?? Colors.white54,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Stack(
              children: [
                Text(appName, style: textTheme.titleMedium),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image(
                    image: appIconImage,
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddMenuTile extends StatelessWidget {
  const AddMenuTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: Colors.white38),
      ),
      child: const SizedBox.expand(
        child: Icon(
          Icons.add_rounded,
          color: Colors.white38,
          size: 48,
        ),
      ),
    );
  }
}

class LoadingTile extends StatelessWidget {
  const LoadingTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: Colors.white38),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          color: Colors.white54,
        ),
      ),
    );
  }
}
