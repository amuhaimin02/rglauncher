import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_storage/saf.dart' as saf;

Future<void> launchGameFromFile() async {
  final grantedUri = await saf.openDocumentTree();
  print(grantedUri);
  final fileStream = saf.listFiles(
    grantedUri!,
    columns: [
      saf.DocumentFileColumn.displayName,
      saf.DocumentFileColumn.size,
      saf.DocumentFileColumn.lastModified,
      saf.DocumentFileColumn.id,
      saf.DocumentFileColumn.mimeType,
    ],
  );
  fileStream.listen((file) {
    print('${file.name}, ${file.type}');
  });

  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'action_main',
      package: 'com.retroarch.aarch64',
      componentName: 'com.retroarch.browser.retroactivity.RetroActivityFuture',
      // category: 'category_launcher',
      flags: [
        Flag.FLAG_ACTIVITY_CLEAR_TASK,
        Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
        Flag.FLAG_ACTIVITY_NO_HISTORY,
        Flag.FLAG_ACTIVITY_NO_ANIMATION
      ],
      arguments: {
        'ROM':
            '/storage/emulated/0/EmuROM/GBA/B/1060 - Advance Wars 2 - Black Hole Rising (U)(Mode7) (patched).gba',
        'LIBRETRO':
            '/data/data/com.retroarch.aarch64/cores/mgba_libretro_android.so',
        'CONFIGFILE':
            '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg',
        'QUITFOCUS': ''
      },
    );
    await intent.launch();
    //   final runCommands = '''
    //   am start
    // -n com.retroarch.aarch64/com.retroarch.browser.retroactivity.RetroActivityFuture
    // -e ROM /storage/emulated/0/EmuROM/GBA/C/luminesweeper-wip.zip
    // -e LIBRETRO /data/data/com.retroarch.aarch64/cores/mgba_libretro_android.so
    // -e CONFIGFILE /storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg
    // -e QUITFOCUS
    // --activity-clear-task
    // --activity-clear-top
    // --activity-no-history
    //   '''
    //       .trim()
    //       .replaceAll('\n', '')
    //       .split(' ')
    //       .where((element) => element.trim().isNotEmpty)
    //       .toList();
    //
    //   print(runCommands);
    //
    //   final result = await Process.run(runCommands.first, runCommands.sublist(1));
    //   print(result.stdout);
    //   print(result.stderr);
  }
}
