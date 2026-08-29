package com.jagx.os

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "jagx_os/launcher"
    private var torchOn = false
    private var cameraId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openHomeSettings" -> openSettings(Settings.ACTION_HOME_SETTINGS, result)
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
                    "openWifi" -> openSettings(Settings.ACTION_WIFI_SETTINGS, result)
                    "openBluetooth" -> openSettings(Settings.ACTION_BLUETOOTH_SETTINGS, result)
                    "openData" -> openSettings(Settings.ACTION_DATA_ROAMING_SETTINGS, result)
                    "openAirplane" -> openSettings(Settings.ACTION_AIRPLANE_MODE_SETTINGS, result)
                    "openLocation" -> openSettings(Settings.ACTION_LOCATION_SOURCE_SETTINGS, result)
                    "openDisplay" -> openSettings(Settings.ACTION_DISPLAY_SETTINGS, result)
                    "openSound" -> openSettings(Settings.ACTION_SOUND_SETTINGS, result)
                    "openCast" -> openSettings(Settings.ACTION_CAST_SETTINGS, result)
                    "openHotspot" -> {
                        try {
                            val intent = Intent()
                            intent.setClassName(
                                "com.android.settings",
                                "com.android.settings.TetherSettings"
                            )
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            openSettings(Settings.ACTION_WIRELESS_SETTINGS, result)
                        }
                    }
                    "openWriteSettings" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                                intent.data = Uri.parse("package:$packageName")
                                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                startActivity(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    }
                    "toggleTorch" -> {
                        try {
                            val on = toggleTorch()
                            result.success(on)
                        } catch (e: Exception) {
                            result.error("TORCH", e.message, null)
                        }
                    }
                    "setBrightness" -> {
                        try {
                            val v = (call.arguments as? Number)?.toFloat() ?: 0.5f
                            setBrightness(v)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BRIGHTNESS", e.message, null)
                        }
                    }
                    "adjustVolume" -> {
                        try {
                            val direction = (call.arguments as? Number)?.toInt() ?: 0
                            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                            if (direction > 0) {
                                am.adjustStreamVolume(
                                    AudioManager.STREAM_MUSIC,
                                    AudioManager.ADJUST_RAISE,
                                    AudioManager.FLAG_SHOW_UI
                                )
                            } else if (direction < 0) {
                                am.adjustStreamVolume(
                                    AudioManager.STREAM_MUSIC,
                                    AudioManager.ADJUST_LOWER,
                                    AudioManager.FLAG_SHOW_UI
                                )
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("VOLUME", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openSettings(action: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(action)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    private fun toggleTorch(): Boolean {
        val cm = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        if (cameraId == null) {
            for (id in cm.cameraIdList) {
                val chars = cm.getCameraCharacteristics(id)
                val flash = chars.get(CameraCharacteristics.FLASH_INFO_AVAILABLE)
                val facing = chars.get(CameraCharacteristics.LENS_FACING)
                if (flash == true && facing == CameraCharacteristics.LENS_FACING_BACK) {
                    cameraId = id
                    break
                }
            }
        }
        val id = cameraId ?: return false
        torchOn = !torchOn
        cm.setTorchMode(id, torchOn)
        return torchOn
    }

    private fun setBrightness(value: Float) {
        // App-window brightness (works without special permission)
        val lp = window.attributes
        lp.screenBrightness = value.coerceIn(0.01f, 1.0f)
        window.attributes = lp
    }
}
