// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('JagX Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('AMOLED-friendly pure black surfaces'),
            value: themeState.mode == ThemeMode.dark,
            onChanged: (_) => themeNotifier.toggle(),
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Accent color'),
            subtitle: const Text('Electric blue (default)'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: JagXColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {},
          ),
          const _SectionHeader('Home screen'),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Layout'),
            subtitle: const Text('4 columns, 2 pages'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.wallpaper),
            title: const Text('Wallpaper'),
            onTap: () {},
          ),
          const _SectionHeader('Gestures'),
          ListTile(
            leading: const Icon(Icons.swipe),
            title: const Text('Gesture navigation'),
            subtitle: const Text('Swipe up for home / apps'),
            onTap: () {},
          ),
          const _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('JagX OS'),
            subtitle: const Text('Version 1.0.0 • JRILICENSE'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'JagX OS',
                applicationVersion: '1.0.0',
                applicationLegalese: 'JRILICENSE\nCopyright © 2026 JagX OS Contributors',
                children: const [
                  SizedBox(height: 16),
                  Text(
                    'A custom Android launcher and system UI designed for a complete OS-like experience on any device, including Itel A100 and beyond.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
