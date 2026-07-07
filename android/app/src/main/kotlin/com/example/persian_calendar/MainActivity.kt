package com.example.persian_calendar

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "persian_calendar/updater"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Directory the APK is downloaded into. Must match res/xml/file_paths.xml.
                    "getApkDir" -> {
                        val dir = File(getExternalFilesDir(null), "updates")
                        if (!dir.exists()) dir.mkdirs()
                        result.success(dir.absolutePath)
                    }
                    // Whether the app is allowed to install packages (Android 8+ gate).
                    "canInstall" -> {
                        val can = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            packageManager.canRequestPackageInstalls()
                        } else {
                            true
                        }
                        result.success(can)
                    }
                    // Sends the user to the "install unknown apps" settings for this app.
                    "requestInstallPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                                .setData(Uri.parse("package:$packageName"))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        }
                        result.success(null)
                    }
                    // Launches the system package installer for the downloaded APK.
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("no_path", "APK path is null", null)
                            return@setMethodCallHandler
                        }
                        try {
                            installApk(path)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("install_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun installApk(path: String) {
        val file = File(path)
        val uri: Uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            file
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
