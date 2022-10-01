import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:rglauncher/configs.dart';

class SlidingTransitionPageRoute<T> extends PageRouteBuilder<T> {
  SlidingTransitionPageRoute({
    required WidgetBuilder builder,
    Axis? direction,
  }) : super(
          pageBuilder: (context, anim1, anim2) => builder(context),
          transitionDuration: defaultAnimationDuration,
          transitionsBuilder: (context, anim1, anim2, child) {
            return SharedAxisTransition(
              animation: anim1,
              secondaryAnimation: anim2,
              transitionType: () {
                if (direction == null) {
                  return SharedAxisTransitionType.scaled;
                }
                switch (direction) {
                  case Axis.vertical:
                    return SharedAxisTransitionType.vertical;
                  case Axis.horizontal:
                    return SharedAxisTransitionType.horizontal;
                }
              }(),
              child: child,
            );
          },
        );
}
