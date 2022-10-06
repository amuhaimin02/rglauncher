import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models.dart';

Future<Map<System, List<File>>> scanLibrariesFromStorage({
  required List<System> systems,
  required List<Directory> storagePaths,
}) async {
  final status = await Permission.manageExternalStorage.request();
  final gameLists = <System, List<File>>{};
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system.folderNames) folderName: system
  };

  if (status == PermissionStatus.granted) {
    for (final path in storagePaths) {
      final folderList = path.listSync(recursive: true).whereType<Directory>();
      for (final folder in folderList) {
        final system = folderToSystemMap[basename(folder.path)];
        if (system != null) {
          if (gameLists[system] == null) {
            gameLists[system] = [];
          }
          gameLists[system]!.addAll(scanDirecstoriesForGames(system, folder));
        }
      }
    }
    for (final system in gameLists.keys) {
      gameLists[system]!
          .sort((a, b) => basename(a.path).compareTo(basename(b.path)));
    }
    return gameLists;
  } else {
    throw const FileSystemException('No access to directories');
  }
}

List<File> scanDirecstoriesForGames(
  System system,
  Directory directory,
) {
  final lowercaseExtensions = system.supportedExtensions;
  final uppercaseExtensions =
      system.supportedExtensions.map((e) => e.toUpperCase());
  final allExtensions =
      List.from([...lowercaseExtensions, ...uppercaseExtensions]);

  final matcher = RegExp('(${allExtensions.join('|')})\$');

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => matcher.hasMatch(file.path))
      .toList();
}

Future<void> launchGameFromFile(File file) async {
  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'action_main',
      package: 'com.retroarch.aarch64',
      componentName: 'com.retroarch.browser.retroactivity.RetroActivityFuture',
      flags: [
        Flag.FLAG_ACTIVITY_CLEAR_TASK,
        Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
        Flag.FLAG_ACTIVITY_NO_HISTORY,
      ],
      arguments: {
        'ROM': file.absolute.path,
        'LIBRETRO':
            '/data/data/com.retroarch.aarch64/cores/mgba_libretro_android.so',
        'CONFIGFILE':
            '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg',
        'QUITFOCUS': ''
      },
    );
    await intent.launch();
  }
}
