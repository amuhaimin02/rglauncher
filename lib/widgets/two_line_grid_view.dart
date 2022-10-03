import 'package:flutter/material.dart';

class TwoLineGridView extends StatelessWidget {
  const TwoLineGridView({
    Key? key,
    required this.children,
    this.childPadding,
    this.padding,
  }) : super(key: key);

  final List<Widget> children;
  final EdgeInsets? childPadding;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final listChildren = <Widget>[];

    Widget? tempWidget;

    Widget mergeChildren(Widget child1, Widget child2) {
      return Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: childPadding ?? EdgeInsets.zero,
                child: child1,
              ),
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: childPadding ?? EdgeInsets.zero,
                child: child2,
              ),
            ),
          ),
        ],
      );
    }

    void placeTempWidgetAlone() {
      if (tempWidget != null) {
        listChildren.add(mergeChildren(tempWidget!, const SizedBox()));
        tempWidget = null;
      }
    }

    for (final c in children) {
      if (c is TwoLineCustomSize) {
        placeTempWidgetAlone();
        listChildren.add(
          AspectRatio(
            aspectRatio: c.aspectRatio,
            child: Padding(
              padding: childPadding ?? EdgeInsets.zero,
              child: c.child,
            ),
          ),
        );
      } else if (c is TwoLineDivider) {
        placeTempWidgetAlone();
        listChildren.add(c);
      } else if (tempWidget != null) {
        listChildren.add(mergeChildren(tempWidget!, c));
        tempWidget = null;
      } else {
        tempWidget = c;
      }
    }
    placeTempWidgetAlone();

    return ListView(
      padding: padding,
      scrollDirection: Axis.horizontal,
      children: listChildren,
    );
  }
}

class TwoLineCustomSize extends StatelessWidget {
  const TwoLineCustomSize({
    Key? key,
    required this.child,
    this.aspectRatio = 1,
  }) : super(key: key);

  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class TwoLineDivider extends StatelessWidget {
  const TwoLineDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: Colors.white38,
      ),
    );
  }
}
