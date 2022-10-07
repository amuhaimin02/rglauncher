import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rglauncher/data/globals.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/data/services.dart';
import 'package:rglauncher/data/tasks.dart';
import 'package:rglauncher/utils/config_loader.dart';
import 'package:rglauncher/widgets/background.dart';

import 'screens/splash_screen.dart';
import 'utils/navigate.dart';
import 'widgets/screen_overlay.dart';

late Map<String, dynamic> systemsConfig;
late Map<String, dynamic> emulatorsConfig;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  print(services<Globals>().privateAppDirectory);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  systemsConfig = await loadConfigFromAsset('config/systems.toml');
  emulatorsConfig = await loadConfigFromAsset('config/emulators.toml');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          Future.microtask(() {
            downloadLinkAndSaveSystemImage(
                systems: ref.watch(allSystemsProvider));
          });
          return MaterialApp(
            title: 'RGLauncher',
            debugShowCheckedModeBanner: false,
            navigatorKey: Navigate.key,
            theme: ThemeData.dark().copyWith(
              textTheme:
                  GoogleFonts.barlowTextTheme(Typography.englishLike2021),
              scaffoldBackgroundColor: Colors.transparent,
              splashFactory: InkRipple.splashFactory,
            ),
            navigatorObservers: [
              ref.watch(routeObserverProvider),
            ],
            builder: (context, child) {
              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overScroll) {
                  overScroll.disallowIndicator();
                  return false;
                },
                child: FocusTraversalGroup(
                  // By default we had to disable this features since it affects joystick navigation
                  descendantsAreTraversable: false,
                  child: Stack(
                    children: [
                      const Background(),
                      child!,
                      const ScreenOverlay(),
                    ],
                  ),
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
