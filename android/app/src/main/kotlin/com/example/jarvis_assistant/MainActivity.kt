package com.example.jarvis_assistant

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "jarvis/app_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")

                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID_PACKAGE", "Package name is missing", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)

                            if (launchIntent == null) {
                                result.error("APP_NOT_FOUND", "App is not installed", null)
                            } else {
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(launchIntent)
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error("LAUNCH_FAILED", e.message, null)
                        }
                    }

                    "openUrl" -> {
                        val url = call.argument<String>("url")

                        if (url.isNullOrBlank()) {
                            result.error("INVALID_URL", "URL is missing", null)
                            return@setMethodCallHandler
                        }

                        try {
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("URL_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
