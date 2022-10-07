import 'package:flutter/material.dart';
import 'package:rglauncher/screens/home_screen.dart';

import '../utils/navigate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Navigate.to((context) => const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
