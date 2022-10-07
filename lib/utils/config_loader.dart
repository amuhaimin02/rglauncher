import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

Future<Map<String, dynamic>> loadConfigFromAsset(String assetPath) async {
  final assetData = await rootBundle.loadString(assetPath);
  return TomlDocument.parse(assetData).toMap();
}
