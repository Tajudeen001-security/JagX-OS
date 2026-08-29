// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary brand colors for JagX OS.
/// Chosen for OLED friendliness, high contrast, and a modern "system" feel.
class JagXColors {
  static const Color primary = Color(0xFF3B82F6);      // Electric blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF8B5CF6);    // Soft violet
  static const Color accent = Color(0xFF06B6D4);       // Cyan accent
  static const Color surfaceDark = Color(0xFF0F0F12);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color error = Color(0xFFEF4444);
}

class JagXThemeState {
  final ThemeMode mode;
  final Color accent;

  const JagXThemeState({
    this.mode = ThemeMode.dark,
    this.accent = JagXColors.primary,
  });

  JagXThemeState copyWith({ThemeMode? mode, Color? accent}) {
    return JagXThemeState(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
    );
  }
}

class ThemeNotifier extends StateNotifier<JagXThemeState> {
  ThemeNotifier() : super(const JagXThemeState());

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);
  void setAccent(Color color) => state = state.copyWith(accent: color);
  void toggle() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, JagXThemeState>((ref) {
  return ThemeNotifier();
});

class JagXTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: JagXColors.primary,
        brightness: Brightness.light,
        primary: JagXColors.primary,
        secondary: JagXColors.secondary,
        surface: JagXColors.surfaceLight,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: JagXColors.surfaceLight,
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: JagXColors.primary,
        brightness: Brightness.dark,
        primary: JagXColors.primary,
        secondary: JagXColors.secondary,
        surface: JagXColors.surfaceDark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: JagXColors.surfaceDark,
    );
  }
}
