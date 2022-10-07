import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/screens/home_screen.dart';

import '../data/services.dart';
import '../data/tasks.dart';
import '../utils/navigate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await initializeServices();
      final systems = await ref.watch(allSystemsProvider.future);
      downloadLinkAndSaveSystemImage(systems: systems);
      Navigate.to((context) => const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
