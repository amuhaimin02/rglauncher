import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rglauncher/configs.dart';
import 'package:rglauncher/providers.dart';
import 'package:rglauncher/screens/system_list_screen.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/gamepad_listener.dart';
import 'package:rglauncher/widgets/sliding_transition_page_route.dart';
import 'package:rglauncher/widgets/two_line_grid_view.dart';

import '../widgets/large_clock.dart';
import 'game_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: CommandWrapper(
        commands: [
          Command(
            button: CommandButton.a,
            label: 'Open',
            onTap: () => _openSystemListScreen(context),
          ),
        ],
        child: GamepadListener(
          key: const ValueKey('home'),
          onDirectional: (direction, repeating) {
            if (direction == GamepadDirection.left) {
              ref.read(selectedMenuIndexProvider.state).state--;
            } else if (direction == GamepadDirection.right) {
              ref.read(selectedMenuIndexProvider.state).state++;
            }
          },
          child: TwoLineGridView(
            padding: const EdgeInsets.all(64),
            childPadding: const EdgeInsets.all(4),
            children: [
              const TwoLineCustomSize(
                aspectRatio: 1.2,
                child: LargeClock(),
              ),
              const TwoLineDivider(),
              const AddMenuTile(),
              const TwoLineDivider(),
              MenuTile(
                label: 'Favorites',
                icon: Icons.favorite_rounded,
                onTap: () => _openSingleListScreen(context, 'Favorites'),
              ),
              MenuTile(
                label: 'Recent',
                icon: Icons.history_rounded,
                onTap: () => _openSingleListScreen(context, 'Recent'),
              ),
              MenuTile(
                label: 'Wishlist',
                icon: Icons.bookmark_rounded,
                onTap: () => _openSingleListScreen(context, 'Wishlist'),
              ),
              MenuTile(
                label: 'New',
                icon: Icons.auto_awesome_rounded,
                onTap: () => _openSingleListScreen(context, 'New'),
              ),
              TwoLineCustomSize(
                aspectRatio: 0.63,
                child: MenuTile(
                  label: 'All systems',
                  icon: Icons.sports_esports_rounded,
                  onTap: () => _openSystemListScreen(context),
                ),
              ),
              const TwoLineDivider(),
              MenuTile(
                label: 'All apps',
                icon: Icons.apps_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSystemListScreen(BuildContext context) {
    Navigator.push(
      context,
      SlidingTransitionPageRoute(
        builder: (context) => const SystemListScreen(),
        direction: Axis.vertical,
      ),
    );
  }

  void _openSingleListScreen(BuildContext context, String title) {
    Navigator.push(
      context,
      SlidingTransitionPageRoute(
        builder: (context) => SingleGameListScreen(
          title: title,
          gameList: List.generate(
              50, (index) => 'Street Fighter ${index + 1}th Edition'),
        ),
        direction: Axis.vertical,
      ),
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
  const MenuTile({Key? key, required this.label, this.onTap, this.icon})
      : super(key: key);

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white38,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
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
      child: InkWell(
        onTap: () {},
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white38,
          size: 48,
        ),
      ),
    );
  }
}
