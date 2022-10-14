import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../data/configs.dart';
import '../data/database.dart';
import '../data/models.dart';

class MediaManager {
  const MediaManager(this.appDirPath);

  final String appDirPath;

  Future<Uint8List> downloadImage(String link) async {
    final response = await http.get(Uri.parse(link));
    return response.bodyBytes;
  }

  File getSystemImageFile(System system) {
    return File('$appDirPath/$systemImageFolderName/${system.code}.png');
  }

  File getGameListFile(System system) {
    return File('$appDirPath/$gameListFolderName/${system.code}.csv');
  }

  void saveSystemImageFile(Uint8List bytes, System system) {
    final imageFile = getSystemImageFile(system);
    if (!imageFile.existsSync()) {
      imageFile.createSync(recursive: true);
    }
    imageFile.writeAsBytesSync(bytes);
  }

  File getGameBoxArtFile(Game game) {
    return File(
        '${game.filepath}/$gameMediaFolderName/${game.fileNameNoExtension}-thumb.png');
  }

  File getGameScreenshotFile(Game game) {
    return File(
        '${game.filepath}/$gameMediaFolderName/${game.fileNameNoExtension}.png');
  }

  bool isGameMediaFileExists(Game game) {
    return getGameBoxArtFile(game).existsSync();
  }

  void saveGameMediaFile(Uint8List imageBytes, Game game) {
    final imageFile = getGameBoxArtFile(game);

    if (!imageFile.existsSync()) {
      imageFile.createSync(recursive: true);
    }
    imageFile.writeAsBytesSync(imageBytes);
  }

  void saveFile(Uint8List imageBytes, File file) {
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytesSync(imageBytes);
  }
}
