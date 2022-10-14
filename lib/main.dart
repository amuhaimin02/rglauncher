import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/widgets/changeable_background.dart';

import 'screens/splash_screen.dart';
import 'utils/navigate.dart';
import 'widgets/screen_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp(
            title: 'RGLauncher',
            debugShowCheckedModeBanner: false,
            navigatorKey: Navigate.key,
            theme: ThemeData.from(
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                secondary: Colors.white,
              ),
              textTheme:
                  GoogleFonts.barlowTextTheme(Typography.englishLike2021),
            ).copyWith(
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
                      const ChangeableBackground(),
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
