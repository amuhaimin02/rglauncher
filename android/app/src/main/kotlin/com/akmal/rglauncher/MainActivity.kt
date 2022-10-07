package com.akmal.rglauncher

import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rglauncher_android_functions").setMethodCallHandler {
                call, result ->
            if (call.method == "convertUriToContentPath") {
                result.success(convertUriToContentPath(call.arguments as String))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun convertUriToContentPath(filepath: String): String {
        val uri: Uri = FileProvider.getUriForFile(
            this,
            BuildConfig.APPLICATION_ID + ".provider",
            File(filepath)
        )
        return uri.toString()
    }
}
