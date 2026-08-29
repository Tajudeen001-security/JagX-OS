// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/services.dart';

class SystemService {
  static const _ch = MethodChannel('jagx_os/launcher');

  static Future<void> openWifi() => _invoke('openWifi');
  static Future<void> openBluetooth() => _invoke('openBluetooth');
  static Future<void> openData() => _invoke('openData');
  static Future<void> openAirplane() => _invoke('openAirplane');
  static Future<void> openLocation() => _invoke('openLocation');
  static Future<void> openDisplay() => _invoke('openDisplay');
  static Future<void> openSound() => _invoke('openSound');
  static Future<void> openCast() => _invoke('openCast');
  static Future<void> openHotspot() => _invoke('openHotspot');
  static Future<void> openWriteSettings() => _invoke('openWriteSettings');

  static Future<bool> toggleTorch() async {
    try {
      final r = await _ch.invokeMethod<bool>('toggleTorch');
      return r ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setBrightness(double v) async {
    try {
      await _ch.invokeMethod('setBrightness', v);
    } catch (_) {}
  }

  static Future<void> volumeUp() => _invoke('adjustVolume', 1);
  static Future<void> volumeDown() => _invoke('adjustVolume', -1);

  static Future<void> _invoke(String method, [dynamic args]) async {
    try {
      await _ch.invokeMethod(method, args);
    } catch (_) {}
  }
}
