import 'package:flutter/material.dart';

class ShadowedText extends StatelessWidget {
  const ShadowedText({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // Colors.black,
            // Colors.transparent,
          ],
        ),
      ),
      child: child,
    );
  }
}
