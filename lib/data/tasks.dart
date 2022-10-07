import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:path/path.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/globals.dart';
import 'package:rglauncher/data/services.dart';
import 'package:rglauncher/utils/android_functions.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

Future<void> downloadLinkAndSaveSystemImage(
    {required List<System> systems}) async {
  final basePath = services<Globals>().privateAppDirectory;
  final imageStoragePath = Directory('${basePath.path}/$systemImageFolderName');
  if (!imageStoragePath.existsSync()) {
    imageStoragePath.create();
  }

  for (final system in systems) {
    final imageLink = system.imageLink;
    final response = await http.get(Uri.parse(imageLink));
    final fileName = '${system.code}.png';
    final imageFile = File('${imageStoragePath.path}/$fileName');
    imageFile.writeAsBytesSync(response.bodyBytes);
  }
}

Future<Map<System, List<File>>> scanLibrariesFromStorage({
  required List<System> systems,
  required List<Directory> storagePaths,
}) async {
  // final status = await Permission.manageExternalStorage.request();
  final gameLists = <System, List<File>>{};
  final folderToSystemMap = {
    for (final system in systems)
      for (final folderName in system.folderNames) folderName: system
  };

  for (final path in storagePaths) {
    final folderList = path.listSync(recursive: true).whereType<Directory>();
    for (final folder in folderList) {
      final system = folderToSystemMap[basename(folder.path)];
      if (system != null) {
        if (gameLists[system] == null) {
          gameLists[system] = [];
        }
        gameLists[system]!.addAll(scanDirectoriesForGames(system, folder));
      }
    }
  }
  for (final system in gameLists.keys) {
    gameLists[system]!
        .sort((a, b) => basename(a.path).compareTo(basename(b.path)));
  }
  return gameLists;
}

Future<Map<System, List<File>>> scanLibrariesFromStorageCompute(
        Map<String, dynamic> args) =>
    scanLibrariesFromStorage(
      systems: args['systems'],
      storagePaths: args['storagePaths'],
    );

List<File> scanDirectoriesForGames(
  System system,
  Directory directory,
) {
  final matcher = RegExp(
    '(${system.supportedExtensions.join('|')})\$',
    caseSensitive: false,
  );

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => matcher.hasMatch(file.path))
      .toList();
}

Future<void> launchGameFromFile(File file, Emulator emulator) async {
  // final result = await AndroidFunctions.runShell(
  //     'am start -n org.ppsspp.ppsspp/.PpssppActivity');
  // print(result);
  // return;
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
              'ROM': file.absolute.path,
              'LIBRETRO': emulator.libretroPath,
              'CONFIGFILE':
                  '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg',
              'QUITFOCUS': ''
            }
          : null,
      data: !emulator.isRetroarch
          ? await AndroidFunctions.convertUriToContentPath(file.path)
          : null,
    );
    await intent.launch();
  }
}
