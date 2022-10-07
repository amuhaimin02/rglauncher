import 'package:flutter/material.dart';

class FadingEdge extends StatelessWidget {
  const FadingEdge({
    Key? key,
    required this.child,
    required this.direction,
    required this.fadingEdgeSize,
  }) : super(key: key);

  final Widget child;
  final Axis direction;
  final double fadingEdgeSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        final edgePercentage = fadingEdgeSize /
            (direction == Axis.vertical ? rect.height : rect.width);
        return LinearGradient(
          begin: direction == Axis.vertical
              ? Alignment.topCenter
              : Alignment.centerLeft,
          end: direction == Axis.vertical
              ? Alignment.bottomCenter
              : Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent
          ],
          stops: [0, edgePercentage, 1 - edgePercentage, 1],
        ).createShader(
          Rect.fromLTRB(0, 0, rect.width, rect.height),
        );
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
