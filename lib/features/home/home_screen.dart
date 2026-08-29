// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/features/status_bar/status_bar.dart';
import 'package:jagx_os/features/drawer/app_drawer.dart';
import 'package:jagx_os/features/quick_settings/quick_settings_panel.dart';

/// Main home screen of JagX OS.
/// Decision: PageView of grids + persistent dock + status bar.
/// Why: Classic launcher pattern that users already understand, easy to extend
/// with folders and widgets later, performs well on low-end devices.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showDrawer = false;
  bool _showQuickSettings = false;

  // Placeholder app list — replace with real installed apps via platform channel.
  final List<_AppItem> _apps = const [
    _AppItem(name: 'Phone', icon: Icons.phone),
    _AppItem(name: 'Messages', icon: Icons.message),
    _AppItem(name: 'Camera', icon: Icons.camera_alt),
    _AppItem(name: 'Gallery', icon: Icons.photo),
    _AppItem(name: 'Settings', icon: Icons.settings),
    _AppItem(name: 'Chrome', icon: Icons.language),
    _AppItem(name: 'Play Store', icon: Icons.shop),
    _AppItem(name: 'Files', icon: Icons.folder),
    _AppItem(name: 'Clock', icon: Icons.access_time),
    _AppItem(name: 'Calculator', icon: Icons.calculate),
    _AppItem(name: 'Music', icon: Icons.music_note),
    _AppItem(name: 'Maps', icon: Icons.map),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() => setState(() => _showDrawer = true);
  void _closeDrawer() => setState(() => _showDrawer = false);
  void _toggleQuickSettings() =>
      setState(() => _showQuickSettings = !_showQuickSettings);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Wallpaper layer
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E1B4B),
                    Color(0xFF0F0F12),
                  ],
                ),
              ),
            ),
          ),

          // Status bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: JagXStatusBar(),
          ),

          // Home pages
          Positioned.fill(
            top: 48,
            bottom: 90,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: 2,
              itemBuilder: (context, pageIndex) {
                final start = pageIndex * 8;
                final end = (start + 8).clamp(0, _apps.length);
                final pageApps = _apps.sublist(start, end);
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: pageApps.length,
                  itemBuilder: (context, i) {
                    final app = pageApps[i];
                    return _AppIcon(
                      name: app.name,
                      icon: app.icon,
                      onTap: () {
                        // TODO: launch real app via android_intent / device_apps
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Launch ${app.name}')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? JagXColors.primary
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Dock
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DockIcon(icon: Icons.phone, label: 'Phone'),
                  _DockIcon(icon: Icons.message, label: 'SMS'),
                  _DockIcon(
                    icon: Icons.apps,
                    label: 'Apps',
                    onTap: _openDrawer,
                  ),
                  _DockIcon(icon: Icons.camera_alt, label: 'Camera'),
                ],
              ),
            ),
          ),

          // Gesture area for swipe-up to drawer (simplified)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 24,
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! < -300) {
                  _openDrawer();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // Quick settings pull-down
          if (_showQuickSettings)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleQuickSettings,
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: QuickSettingsPanel(onClose: _toggleQuickSettings),
                  ),
                ),
              ),
            ),

          // App drawer overlay
          if (_showDrawer)
            Positioned.fill(
              child: AppDrawer(
                apps: _apps,
                onClose: _closeDrawer,
              ),
            ),
        ],
      ),
    );
  }
}

class _AppItem {
  final String name;
  final IconData icon;
  const _AppItem({required this.name, required this.icon});
}

class _AppIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _AppIcon({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DockIcon({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
