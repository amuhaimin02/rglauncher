import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/screens/system_list_screen.dart';
import 'package:rglauncher/utils/extensions.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/gamepad_listener.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';
import 'package:rglauncher/widgets/two_line_grid_view.dart';

import '../utils/navigate.dart';
import '../widgets/large_clock.dart';
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
    final allApps = ref.watch(installedAppsProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: CommandWrapper(
        commands: [
          Command(
            button: CommandButton.a,
            label: 'Open',
            onTap: (context) => _onButtonAPressed(context),
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
            childPadding: const EdgeInsets.all(4),
            onItemArranged: (types) => _itemTypes = types,
            itemLauncherCallback: (launcher) => _itemLauncher = launcher,
            items: [
              const TwoLineGridItem(
                large: true,
                aspectRatio: 1.2,
                child: LargeClock(),
              ),
              const TwoLineDivider(),
              const TwoLineGridItem(
                child: AddMenuTile(),
              ),
              const TwoLineDivider(),
              TwoLineGridItem(
                onTap: () => _openSingleListScreen(context, 'Favorites'),
                child: const MenuTile(
                  label: 'Favorites',
                  icon: Icons.favorite_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () => _openSingleListScreen(context, 'Recent'),
                child: const MenuTile(
                  label: 'Recent',
                  icon: Icons.history_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () => _openSingleListScreen(context, 'Wishlist'),
                child: const MenuTile(
                  label: 'Wishlist',
                  icon: Icons.bookmark_rounded,
                ),
              ),
              TwoLineGridItem(
                onTap: () => _openSingleListScreen(context, 'New'),
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
              ...allApps.when(
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
              const TwoLineGridItem(
                child: MenuTile(
                  label: 'All apps',
                  icon: Icons.apps_rounded,
                ),
              ),
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
      direction: Axis.vertical,
    );
  }

  void _openSingleListScreen(BuildContext context, String title) {
    Navigate.to(
      (context) => SingleGameListScreen(
        title: title,
        gameList: const [],
      ),
      direction: Axis.vertical,
    );
  }

  void _onButtonAPressed(BuildContext context) {
    final selectedIndex = ref.read(selectedMenuIndexProvider);
    _itemLauncher(selectedIndex);
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
  const MenuTile({Key? key, required this.label, this.icon}) : super(key: key);

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white38,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Stack(
          children: [
            Text(label, style: textTheme.titleLarge),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                size: 56,
                color: Colors.white38,
              ),
            ),
          ],
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
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.orange.shade200.withOpacity(0.54),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Stack(
          children: [
            Text(appName, style: textTheme.titleMedium),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.memory(
                icon,
                width: 60,
                height: 60,
              ),
            ),
          ],
        ),
      ),
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
