import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../data/configs.dart';
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

  void saveSystemImageFile(Uint8List bytes, System system) {
    final imageFile = getSystemImageFile(system);
    if (!imageFile.parent.existsSync()) {
      imageFile.parent.createSync();
    }
    imageFile.writeAsBytesSync(bytes);
  }

  File getGameMediaFile(Game game) {
    final gameFile = File(game.filepath);
    return File(
        '${gameFile.parent.path}/$gameMediaFolderName/${basename(gameFile.path)}.png');
  }

  bool isGameMediaFileExists(Game game) {
    return getGameMediaFile(game).existsSync();
  }

  void saveGameMediaFile(Uint8List imageBytes, Game game) {
    final imageFile = getGameMediaFile(game);

    if (!imageFile.parent.existsSync()) {
      imageFile.parent.createSync();
    }
    imageFile.writeAsBytesSync(imageBytes);
  }
}
