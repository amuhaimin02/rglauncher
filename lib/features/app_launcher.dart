import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:rglauncher/features/services.dart';

import '../data/database.dart';
import '../data/models.dart';
import 'android_functions.dart';

class AppLauncher {
  const AppLauncher();

  Future<void> launchGameUsingEmulator(Game game, Emulator emulator) async {
    final db = services<Database>();
    db.toggleFavorite(game);
    db.updateLastPlayed(game);
    db.pinGame(game, 0);
    print('Launching $game');

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: emulator.isRetroarch ? 'action_main' : 'action_view',
        // action: 'action_main',
        package: emulator.androidPackageName,
        componentName: emulator.androidComponentName,
        flags: [
          Flag.FLAG_ACTIVITY_CLEAR_TASK,
          Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
          Flag.FLAG_ACTIVITY_NO_HISTORY,
          1 // FLAG_GRANT_READ_URI_PERMISSION
        ],
        arguments: emulator.isRetroarch
            ? {
                'ROM': File(game.fullpath).absolute.path,
                'LIBRETRO': emulator.libretroPath,
                'CONFIGFILE':
                    '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg',
                'QUITFOCUS': ''
              }
            : null,
        data: !emulator.isRetroarch
            ? await AndroidFunctions.convertUriToContentPath(
                File(game.fullpath).path)
            : null,
      );
      await intent.launch();
    }
  }
}
