import 'package:flutter/material.dart';
import 'package:rglauncher/widgets/changeable_background.dart';

class LauncherScaffold extends StatelessWidget {
  const LauncherScaffold({Key? key, required this.body, this.backgroundImage})
      : super(key: key);

  final Widget body;
  final ImageProvider? backgroundImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        image: backgroundImage,
        child: body,
      ),
    );
  }
}
