import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../data/database.dart';
import '../data/models.dart';
import 'android_functions.dart';

class AppLauncher {
  const AppLauncher();

  Future<void> launchGameUsingEmulator(Game game, Emulator emulator) async {
    // final result = await AndroidFunctions.runShell(
    //     'am start -n org.ppsspp.ppsspp/.PpssppActivity');
    // print(result);
    // return;
    // if (Platform.isAndroid) {
    //   final intent = AndroidIntent(
    //     action: emulator.isRetroarch ? 'action_main' : 'action_view',
    //     // action: 'action_main',
    //     package: emulator.androidPackageName,
    //     componentName: emulator.androidComponentName,
    //     flags: [
    //       Flag.FLAG_ACTIVITY_CLEAR_TASK,
    //       Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
    //       Flag.FLAG_ACTIVITY_NO_HISTORY,
    //       1 // FLAG_GRANT_READ_URI_PERMISSION
    //     ],
    //     arguments: emulator.isRetroarch
    //         ? {
    //             'ROM': File(game.filepath).absolute.path,
    //             'LIBRETRO': emulator.libretroPath,
    //             'CONFIGFILE':
    //                 '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg',
    //             'QUITFOCUS': ''
    //           }
    //         : null,
    //     data: !emulator.isRetroarch
    //         ? await AndroidFunctions.convertUriToContentPath(
    //             File(game.filepath).path)
    //         : null,
    //   );
    //   await intent.launch();
    // }
  }
}
