import 'package:flutter/material.dart';

class HueBackground extends StatefulWidget {
  const HueBackground({Key? key}) : super(key: key);

  @override
  State<HueBackground> createState() => _HueBackgroundState();
}

class _HueBackgroundState extends State<HueBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        color: HSVColor.fromAHSV(1, _controller.value * 360, 1, 0.4).toColor(),
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
