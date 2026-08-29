// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/services/app_service.dart';
import 'package:jagx_os/features/status_bar/status_bar.dart';
import 'package:jagx_os/features/drawer/app_drawer.dart';
import 'package:jagx_os/features/quick_settings/quick_settings_panel.dart';

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

  // Common system apps we try to pin in the dock by package name patterns
  static const _dockPackages = [
    'com.android.dialer',
    'com.google.android.dialer',
    'com.android.contacts',
    'com.transsion.dialer',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() => setState(() => _showDrawer = true);
  void _closeDrawer() => setState(() => _showDrawer = false);

  Future<void> _launch(AppInfo app) async {
    final ok = await launchApp(app.packageName ?? '');
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${app.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedAppsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Wallpaper
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

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: JagXStatusBar(),
          ),

          // Home pages with real apps
          Positioned.fill(
            top: 48,
            bottom: 90,
            child: appsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: JagXColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Could not load apps\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return const Center(
                    child: Text(
                      'No apps found.\nCheck QUERY_ALL_PACKAGES permission.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                // Show first 16 apps on home (2 pages × 8)
                final homeApps = apps.take(16).toList();
                final pageCount = (homeApps.length / 8).ceil().clamp(1, 4);

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: pageCount,
                  itemBuilder: (context, pageIndex) {
                    final start = pageIndex * 8;
                    final end = (start + 8).clamp(0, homeApps.length);
                    final pageApps = homeApps.sublist(start, end);

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: pageApps.length,
                      itemBuilder: (context, i) {
                        final app = pageApps[i];
                        return _RealAppIcon(
                          app: app,
                          onTap: () => _launch(app),
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
            child: appsAsync.maybeWhen(
              data: (apps) {
                final pageCount = ((apps.take(16).length) / 8).ceil().clamp(1, 4);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageCount, (i) {
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
                );
              },
              orElse: () => const SizedBox.shrink(),
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
                  _DockIcon(
                    icon: Icons.phone,
                    label: 'Phone',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final phone = apps.where((a) =>
                          (a.packageName ?? '').contains('dialer') ||
                          (a.name ?? '').toLowerCase().contains('phone')).firstOrNull;
                      if (phone != null) _launch(phone);
                    },
                  ),
                  _DockIcon(
                    icon: Icons.message,
                    label: 'SMS',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final sms = apps.where((a) =>
                          (a.packageName ?? '').contains('mms') ||
                          (a.packageName ?? '').contains('messaging') ||
                          (a.name ?? '').toLowerCase().contains('message')).firstOrNull;
                      if (sms != null) _launch(sms);
                    },
                  ),
                  _DockIcon(
                    icon: Icons.apps,
                    label: 'Apps',
                    onTap: _openDrawer,
                  ),
                  _DockIcon(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final cam = apps.where((a) =>
                          (a.packageName ?? '').contains('camera') ||
                          (a.name ?? '').toLowerCase() == 'camera').firstOrNull;
                      if (cam != null) _launch(cam);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Swipe up for drawer
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

          if (_showDrawer)
            Positioned.fill(
              child: AppDrawer(onClose: _closeDrawer),
            ),
        ],
      ),
    );
  }
}

class _RealAppIcon extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;

  const _RealAppIcon({required this.app, required this.onTap});

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
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: app.icon != null
                ? Image.memory(app.icon!, fit: BoxFit.cover)
                : const Icon(Icons.android, color: Colors.white70, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            app.name ?? 'App',
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

  const _DockIcon({required this.icon, required this.label, this.onTap});

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
