import 'dart:io';
import 'dart:typed_data';

import '../data/configs.dart';
import '../data/models.dart';

class MediaManager {
  const MediaManager(this.appDirPath);

  final String appDirPath;

  File getSystemImageFile(System system) {
    return File('$appDirPath/$systemImageFolderName/${system.code}.png');
  }

  void saveSystemImageFile(Uint8List bytes, System system) {
    final imageStoragePath = Directory('$appDirPath/$systemImageFolderName');
    if (!imageStoragePath.existsSync()) {
      imageStoragePath.create();
    }
    final fileName = '${system.code}.png';
    final imageFile = File('${imageStoragePath.path}/$fileName');
    imageFile.writeAsBytesSync(bytes);
  }
}
