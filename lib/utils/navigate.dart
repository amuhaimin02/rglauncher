import 'package:flutter/cupertino.dart';
import 'package:rglauncher/widgets/sliding_transition_page_route.dart';

class Navigate {
  static final key = GlobalKey<NavigatorState>();

  static void to(WidgetBuilder builder, {Axis? direction}) {
    key.currentState!.push(
      SlidingTransitionPageRoute(
        builder: builder,
        direction: direction,
      ),
    );
  }

  static void back() {
    key.currentState!.pop();
  }
}
