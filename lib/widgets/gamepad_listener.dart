import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class GamepadListener extends ConsumerStatefulWidget {
  const GamepadListener({
    required Key key,
    required this.child,
    this.onDirectional,
    this.onLeftShoulder,
    this.onRightShoulder,
    this.onA,
    this.onB,
    this.onX,
    this.onY,
  }) : super(key: key);

  final Widget child;
  final Function(GamepadDirection direction, bool repeating)? onDirectional;
  final VoidCallback? onLeftShoulder;
  final VoidCallback? onRightShoulder;
  final VoidCallback? onA;
  final VoidCallback? onB;
  final VoidCallback? onX;
  final VoidCallback? onY;

  @override
  ConsumerState<GamepadListener> createState() => _GamepadListenerState();
}

class _GamepadListenerState extends ConsumerState<GamepadListener>
    with RouteAware {
  late final _focusNode = FocusNode();

  KeyEvent? _lastKeyEvent;

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
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void didPopNext() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    void defaultBackAction() {
      if (ModalRoute.of(context)?.isFirst == false) {
        Navigator.pop(context);
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (keyEvent) {
        final isRepeating = keyEvent is KeyRepeatEvent;

        if (keyEvent is KeyUpEvent && _lastKeyEvent is! KeyRepeatEvent) {
          return;
        }

        // TODO: There is an issue using switch-case statement here
        if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
          widget.onDirectional?.call(GamepadDirection.up, isRepeating);
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
          widget.onDirectional?.call(GamepadDirection.down, isRepeating);
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft) {
          widget.onDirectional?.call(GamepadDirection.left, isRepeating);
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowRight) {
          widget.onDirectional?.call(GamepadDirection.right, isRepeating);
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.gameButtonY) {
          widget.onLeftShoulder?.call();
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.gameButtonZ) {
          widget.onRightShoulder?.call();
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.gameButtonC ||
            keyEvent.logicalKey == LogicalKeyboardKey.enter) {
          widget.onA?.call();
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.gameButtonB ||
            keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
          (widget.onB ?? defaultBackAction).call();
        }
        _lastKeyEvent = keyEvent;
      },
      child: widget.child,
    );
  }
}

enum GamepadDirection { up, down, left, right }
