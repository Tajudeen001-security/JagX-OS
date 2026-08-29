// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

/// Loads and caches the real apps installed on the device.
final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  try {
    // excludeSystemApps: false so Phone, Settings, Camera etc. still appear
    final apps = await InstalledApps.getInstalledApps(
      true,  // withIcon
      true,  // withVersionName (not critical)
    );
    // Sort alphabetically for a clean drawer
    apps.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
    return apps;
  } catch (e) {
    debugPrint('Failed to load installed apps: $e');
    return [];
  }
});

/// Launch an app by package name.
Future<bool> launchApp(String packageName) async {
  try {
    return await InstalledApps.startApp(packageName) ?? false;
  } catch (e) {
    debugPrint('Failed to launch $packageName: $e');
    return false;
  }
}
