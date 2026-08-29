// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum JagXThemeId {
  matrix,      // classic green-on-black hacker
  cyberpunk,   // neon pink / cyan
  ghost,       // minimal white-on-black terminal
  blood,       // red / black threat mode
  ocean,       // deep blue calm
  amber,       // warm terminal amber
}

class JagXThemeData {
  final JagXThemeId id;
  final String name;
  final String tagline;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color textDim;
  final Color glow;
  final Color danger;

  const JagXThemeData({
    required this.id,
    required this.name,
    required this.tagline,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textDim,
    required this.glow,
    required this.danger,
  });
}

const themes = <JagXThemeId, JagXThemeData>{
  JagXThemeId.matrix: JagXThemeData(
    id: JagXThemeId.matrix,
    name: 'MATRIX',
    tagline: 'Wake up, Neo',
    primary: Color(0xFF00FF41),
    secondary: Color(0xFF008F11),
    accent: Color(0xFF39FF14),
    background: Color(0xFF000000),
    surface: Color(0xFF0A0F0A),
    text: Color(0xFF00FF41),
    textDim: Color(0xFF00AA2A),
    glow: Color(0xFF00FF41),
    danger: Color(0xFFFF003C),
  ),
  JagXThemeId.cyberpunk: JagXThemeData(
    id: JagXThemeId.cyberpunk,
    name: 'CYBERPUNK',
    tagline: 'High tech, low life',
    primary: Color(0xFFFF2A6D),
    secondary: Color(0xFF05D9E8),
    accent: Color(0xFFD1F7FF),
    background: Color(0xFF0D0221),
    surface: Color(0xFF1A0A2E),
    text: Color(0xFFD1F7FF),
    textDim: Color(0xFF05D9E8),
    glow: Color(0xFFFF2A6D),
    danger: Color(0xFFFF003C),
  ),
  JagXThemeId.ghost: JagXThemeData(
    id: JagXThemeId.ghost,
    name: 'GHOST',
    tagline: 'Invisible protocol',
    primary: Color(0xFFE0E0E0),
    secondary: Color(0xFF888888),
    accent: Color(0xFFFFFFFF),
    background: Color(0xFF050505),
    surface: Color(0xFF111111),
    text: Color(0xFFE8E8E8),
    textDim: Color(0xFF777777),
    glow: Color(0xFFCCCCCC),
    danger: Color(0xFFFF4444),
  ),
  JagXThemeId.blood: JagXThemeData(
    id: JagXThemeId.blood,
    name: 'BLOOD',
    tagline: 'Root access granted',
    primary: Color(0xFFFF003C),
    secondary: Color(0xFF8B0000),
    accent: Color(0xFFFF6B6B),
    background: Color(0xFF0A0000),
    surface: Color(0xFF1A0505),
    text: Color(0xFFFFCCCC),
    textDim: Color(0xFFAA4444),
    glow: Color(0xFFFF003C),
    danger: Color(0xFFFF0000),
  ),
  JagXThemeId.ocean: JagXThemeData(
    id: JagXThemeId.ocean,
    name: 'OCEAN',
    tagline: 'Deep net dive',
    primary: Color(0xFF00D4FF),
    secondary: Color(0xFF0077B6),
    accent: Color(0xFF90E0EF),
    background: Color(0xFF001219),
    surface: Color(0xFF001F2B),
    text: Color(0xFFCAF0F8),
    textDim: Color(0xFF48CAE4),
    glow: Color(0xFF00D4FF),
    danger: Color(0xFFFF6B6B),
  ),
  JagXThemeId.amber: JagXThemeData(
    id: JagXThemeId.amber,
    name: 'AMBER',
    tagline: 'Old terminal core',
    primary: Color(0xFFFFB000),
    secondary: Color(0xFFCC8800),
    accent: Color(0xFFFFD700),
    background: Color(0xFF0C0A00),
    surface: Color(0xFF1A1500),
    text: Color(0xFFFFE4A0),
    textDim: Color(0xFFAA8800),
    glow: Color(0xFFFFB000),
    danger: Color(0xFFFF4400),
  ),
};

class ThemeNotifier extends StateNotifier<JagXThemeData> {
  ThemeNotifier() : super(themes[JagXThemeId.matrix]!) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('jagx_theme') ?? 'matrix';
    final themeId = JagXThemeId.values.firstWhere(
      (e) => e.name == id,
      orElse: () => JagXThemeId.matrix,
    );
    state = themes[themeId]!;
  }

  Future<void> setTheme(JagXThemeId id) async {
    state = themes[id]!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jagx_theme', id.name);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, JagXThemeData>((ref) {
  return ThemeNotifier();
});

/// Build Material ThemeData from current JagX theme
ThemeData buildMaterialTheme(JagXThemeData t) {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.dark(
      primary: t.primary,
      secondary: t.secondary,
      surface: t.surface,
      error: t.danger,
    ),
    scaffoldBackgroundColor: t.background,
    textTheme: GoogleFonts.shareTechMonoTextTheme(base.textTheme).apply(
      bodyColor: t.text,
      displayColor: t.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.shareTechMono(
        color: t.primary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
  );
}
