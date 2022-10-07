import 'package:flutter/services.dart';

class AndroidFunctions {
  static const platform = MethodChannel('rglauncher_android_functions');

  static Future<String> convertUriToContentPath(String filepath) async {
    return await platform.invokeMethod('convertUriToContentPath', filepath);
  }
}
