import 'package:flutter/services.dart';

class AndroidFunctions {
  static const platform = MethodChannel('rglauncher_android_functions');

  static Future<String> convertUriToContentPath(String filepath) async {
    return await platform.invokeMethod('convertUriToContentPath', filepath);
  }

  static Future<String> runShell(String command) async {
    return await platform.invokeMethod('runShell', command);
  }
}
