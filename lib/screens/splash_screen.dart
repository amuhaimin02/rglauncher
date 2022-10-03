import 'package:flutter/material.dart';
import 'package:rglauncher/screens/home_screen.dart';
import 'package:rglauncher/widgets/sliding_transition_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Navigator.push(
        context,
        SlidingTransitionPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
