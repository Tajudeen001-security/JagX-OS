// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class QuickSettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const QuickSettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 48, left: 12, right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Quick Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _QsTile(icon: Icons.wifi, label: 'Wi-Fi', active: true),
              _QsTile(icon: Icons.bluetooth, label: 'Bluetooth'),
              _QsTile(icon: Icons.flashlight_on, label: 'Flashlight'),
              _QsTile(icon: Icons.airplanemode_active, label: 'Airplane'),
              _QsTile(icon: Icons.mobiledata_off, label: 'Mobile Data'),
              _QsTile(icon: Icons.brightness_6, label: 'Brightness'),
              _QsTile(icon: Icons.do_not_disturb, label: 'DND'),
              _QsTile(icon: Icons.location_on, label: 'Location'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.brightness_low, color: Colors.white54, size: 20),
              Expanded(
                child: Slider(
                  value: 0.6,
                  onChanged: (_) {},
                  activeColor: JagXColors.primary,
                  inactiveColor: Colors.white24,
                ),
              ),
              const Icon(Icons.brightness_high, color: Colors.white54, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _QsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _QsTile({
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
            color: active ? JagXColors.primary : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
