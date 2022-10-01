import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/screens/system_list_screen.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/gamepad_listener.dart';
import 'package:rglauncher/widgets/sliding_transition_page_route.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommandWrapper(
      commands: [
        Command(
          button: CommandButton.a,
          label: 'Open',
          onTap: () => _openSystemListScreen(context),
        ),
      ],
      child: Scaffold(
        body: GamepadListener(
          key: const ValueKey('home'),
          onA: () => _openSystemListScreen(context),
          child: const HomePage(),
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
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(64),
      children: [
        for (int i = 0; i < 20; i++)
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white54,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
      ],
    );
  }
}
