package com.jagx.os

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "jagx_os/launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openHomeSettings" -> {
                        try {
                            // Preferred way on modern Android
                            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            // Fallback for older / OEM devices (Itel, Transsion, etc.)
                            try {
                                val intent = Intent(Intent.ACTION_MAIN)
                                intent.addCategory(Intent.CATEGORY_HOME)
                                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                startActivity(Intent.createChooser(intent, "Select Home app"))
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("UNAVAILABLE", "Could not open Home settings", null)
                            }
                        }
                    }
                    "openHomeSettingsFallback" -> {
                        try {
                            val intent = Intent(Intent.ACTION_MAIN)
                            intent.addCategory(Intent.CATEGORY_HOME)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(Intent.createChooser(intent, "Choose Home app"))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
