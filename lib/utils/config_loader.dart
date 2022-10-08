import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

import '../data/typedefs.dart';

Future<JsonMap> loadConfigFromAsset(String assetPath) async {
  final assetData = await rootBundle.loadString(assetPath);
  return TomlDocument.parse(assetData).toMap();
}
