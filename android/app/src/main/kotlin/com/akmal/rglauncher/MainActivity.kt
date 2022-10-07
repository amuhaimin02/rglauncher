package com.akmal.rglauncher

import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader


class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rglauncher_android_functions"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "convertUriToContentPath" -> {
                    result.success(convertUriToContentPath(call.arguments as String))
                }
                "runShell" -> {
                    result.success(runShell(call.arguments as String))
                }
                else -> {
                    result.notImplemented()
                }
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

    private fun runShell(command: String): String {
        val stdOut = StringBuilder()
        val stdErr = StringBuilder()
        val process = Runtime.getRuntime().exec(command)

        try {
            process?.waitFor()
        } catch (e: InterruptedException) {
            e.printStackTrace();
        }

        return if (process.exitValue() != 0) {
            val errReader = BufferedReader(InputStreamReader(process.errorStream))
            var errCh: Int
            while (errReader.read().also { errCh = it } != -1) {
                stdErr.append(errCh.toChar())
            }
            stdErr.toString()
        } else {
            val inReader = BufferedReader(InputStreamReader(process.inputStream))
            var inCh: Int
            while (inReader.read().also { inCh = it } != -1) {
                stdOut.append(inCh.toChar())
            }
            stdOut.toString()
        }
    }


}
