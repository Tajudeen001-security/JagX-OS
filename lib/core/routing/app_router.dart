// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:jagx_os/features/home/home_screen.dart';
import 'package:jagx_os/features/settings/settings_screen.dart';
import 'package:jagx_os/features/lock_screen/lock_screen.dart';
import 'package:jagx_os/features/onboarding/onboarding_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';
  static const String lock = '/lock';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case lock:
        return MaterialPageRoute(builder: (_) => const LockScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
