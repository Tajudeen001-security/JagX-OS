// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors
// Licensed under JRILICENSE. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/routing/app_router.dart';
import 'package:jagx_os/features/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const ProviderScope(child: JagXApp()));
}

class JagXApp extends ConsumerWidget {
  const JagXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'JagX OS',
      debugShowCheckedModeBanner: false,
      theme: JagXTheme.light,
      darkTheme: JagXTheme.dark,
      themeMode: theme.mode,
      home: const OnboardingGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// Simple gate that shows onboarding on first launch, otherwise home.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real build this would check SharedPreferences.
    // For the scaffold we start at home after a short delay / skip.
    return const OnboardingScreen();
  }
}
