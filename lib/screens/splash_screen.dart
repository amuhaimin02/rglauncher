import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/screens/home_screen.dart';

import '../features/library_manager.dart';
import '../features/services.dart';
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
      final notifier = ref.read(notificationProvider.notifier);
      await notifier.runTask(
        initialLabel: 'Loading library...',
        task: (update) async {
          await initializeServices();
          await services<LibraryManager>().preloadData();
          await services<LibraryManager>().scanLibrariesFromStorage(
            storagePaths: [Directory('/storage/emulated/0/EmuROM')],
          );
        },
      );

      Navigate.to((context) => const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
