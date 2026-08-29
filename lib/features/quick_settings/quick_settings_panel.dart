// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class QuickSettingsPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const QuickSettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.only(top: 48, left: 12, right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withOpacity(0.2),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '> QUICK_SETTINGS',
                style: GoogleFonts.shareTechMono(
                  color: theme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: theme.primary, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QsTile(theme: theme, icon: Icons.wifi, label: 'Wi-Fi', active: true),
              _QsTile(theme: theme, icon: Icons.bluetooth, label: 'BT'),
              _QsTile(theme: theme, icon: Icons.flashlight_on, label: 'FLASH'),
              _QsTile(theme: theme, icon: Icons.airplanemode_active, label: 'AIR'),
              _QsTile(theme: theme, icon: Icons.mobiledata_off, label: 'DATA'),
              _QsTile(theme: theme, icon: Icons.brightness_6, label: 'BRIGHT'),
              _QsTile(theme: theme, icon: Icons.do_not_disturb, label: 'DND'),
              _QsTile(theme: theme, icon: Icons.location_on, label: 'GPS'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.brightness_low, color: theme.textDim, size: 18),
              Expanded(
                child: Slider(
                  value: 0.6,
                  onChanged: (_) {},
                  activeColor: theme.primary,
                  inactiveColor: theme.primary.withOpacity(0.2),
                ),
              ),
              Icon(Icons.brightness_high, color: theme.textDim, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _QsTile extends StatelessWidget {
  final JagXThemeData theme;
  final IconData icon;
  final String label;
  final bool active;

  const _QsTile({
    required this.theme,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: active ? theme.primary.withOpacity(0.25) : theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? theme.primary : theme.primary.withOpacity(0.25),
            ),
          ),
          child: Icon(icon, color: theme.primary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: theme.textDim,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
