import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../providers.dart';

class CommandInfo extends ConsumerWidget {
  const CommandInfo({Key? key}) : super(key: key);

  static final commandButtonIcons = {
    CommandButton.a: MdiIcons.alphaACircle,
    CommandButton.b: MdiIcons.alphaBCircle,
    CommandButton.x: MdiIcons.alphaXCircle,
    CommandButton.y: MdiIcons.alphaYCircle,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandList = ref.watch(commandProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final c in commandList)
            Material(
              key: ValueKey(c.button),
              type: MaterialType.transparency,
              child: InkWell(
                onTap: c.onTap,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    children: [
                      Icon(commandButtonIcons[c.button]),
                      const SizedBox(width: 4),
                      Text(c.label),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class CommandWrapper extends ConsumerStatefulWidget {
  const CommandWrapper({Key? key, required this.child, required this.commands})
      : super(key: key);

  final Widget child;
  final List<Command> commands;

  @override
  ConsumerState<CommandWrapper> createState() => _CommandWrapperState();
}

class _CommandWrapperState extends ConsumerState<CommandWrapper>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .watch(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    ref.watch(routeObserverProvider).unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    assignCommands();
  }

  @override
  void didPopNext() {
    assignCommands();
  }

  void assignCommands() {
    Future.microtask(() {
      ref.read(commandProvider.state).state = widget.commands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class Command {
  final CommandButton button;
  final String label;
  final VoidCallback onTap;

  const Command({
    required this.button,
    required this.label,
    required this.onTap,
  });
}

enum CommandButton { a, b, x, y, select, start }
