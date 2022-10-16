import 'package:flutter/material.dart';

class ShadowedText extends StatelessWidget {
  const ShadowedText({Key? key, required this.child, this.enabled = true})
      : super(key: key);

  final Widget child;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
