import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Globals {
  Globals({
    required this.privateAppDirectory,
  });

  final Directory privateAppDirectory;

  static Future<Globals> setup() async {
    return Globals(
      privateAppDirectory: await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory(),
    );
  }
}
