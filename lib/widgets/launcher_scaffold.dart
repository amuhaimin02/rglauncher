import 'package:flutter/material.dart';
import 'package:rglauncher/widgets/background.dart';

import 'screen_overlay.dart';

class LauncherScaffold extends StatelessWidget {
  const LauncherScaffold({Key? key, required this.body}) : super(key: key);

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
    );
  }
}
