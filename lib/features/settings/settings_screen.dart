// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openHomeSettings() async {
    const channel = MethodChannel('jagx_os/launcher');
    try {
      await channel.invokeMethod('openHomeSettings');
    } catch (_) {
      try {
        await channel.invokeMethod('openHomeSettingsFallback');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          '> SYSTEM_CONFIG',
          style: GoogleFonts.shareTechMono(
            color: theme.primary,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(label: 'THEME_PROTOCOL', color: theme.primary),
          const SizedBox(height: 12),
          ...JagXThemeId.values.map((id) {
            final t = themes[id]!;
            final selected = theme.id == id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => notifier.setTheme(id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? t.primary : t.primary.withOpacity(0.25),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: t.glow.withOpacity(0.35),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [t.primary, t.secondary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: GoogleFonts.shareTechMono(
                                color: t.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              t.tagline,
                              style: GoogleFonts.shareTechMono(
                                color: t.textDim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle, color: t.primary, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          _SectionLabel(label: 'LAUNCHER_CONTROL', color: theme.primary),
          const SizedBox(height: 12),
          _ActionTile(
            theme: theme,
            icon: Icons.home_filled,
            title: 'SET AS DEFAULT HOME',
            subtitle: 'Make JagX OS the system launcher',
            onTap: _openHomeSettings,
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'SYSTEM_INFO', color: theme.primary),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(theme: theme, k: 'OS', v: 'JagX OS v1.1'),
                _InfoLine(theme: theme, k: 'LICENSE', v: 'JRILICENSE'),
                _InfoLine(theme: theme, k: 'MODE', v: theme.name),
                _InfoLine(theme: theme, k: 'STATUS', v: 'ONLINE'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'JRILICENSE // JAGX_CORE',
              style: GoogleFonts.shareTechMono(
                color: theme.textDim,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '// $label',
      style: GoogleFonts.shareTechMono(
        color: color,
        fontSize: 12,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final JagXThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primary.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.shareTechMono(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.shareTechMono(
                      color: theme.textDim,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.primary),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final JagXThemeData theme;
  final String k;
  final String v;
  const _InfoLine({required this.theme, required this.k, required this.v});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              k,
              style: GoogleFonts.shareTechMono(
                color: theme.textDim,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            v,
            style: GoogleFonts.shareTechMono(
              color: theme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
