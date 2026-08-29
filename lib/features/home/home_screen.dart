// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/services/app_service.dart';
import 'package:jagx_os/features/status_bar/status_bar.dart';
import 'package:jagx_os/features/drawer/app_drawer.dart';
import 'package:jagx_os/features/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showDrawer = false;

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
        SnackBar(content: Text('FAILED :: ${app.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final appsAsync = ref.watch(installedAppsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Dark base + subtle grid feel
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.background,
                    theme.surface,
                    theme.background,
                  ],
                ),
              ),
            ),
          ),

          // Top status
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: JagXStatusBar(),
          ),

          // Header label
          Positioned(
            top: 52,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Text(
                  '> HOME_SHELL',
                  style: GoogleFonts.shareTechMono(
                    color: theme.primary,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'CFG',
                      style: GoogleFonts.shareTechMono(
                        color: theme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Apps grid
          Positioned.fill(
            top: 80,
            bottom: 90,
            child: appsAsync.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: theme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'SCANNING_PACKAGES...',
                      style: GoogleFonts.shareTechMono(
                        color: theme.primary,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'ERR :: $e',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(color: theme.danger),
                ),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return Center(
                    child: Text(
                      'NO_PACKAGES_FOUND',
                      style: GoogleFonts.shareTechMono(color: theme.textDim),
                    ),
                  );
                }

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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: pageApps.length,
                      itemBuilder: (context, i) {
                        final app = pageApps[i];
                        return _HackerAppIcon(
                          app: app,
                          theme: theme,
                          onTap: () => _launch(app),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Page dots
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: appsAsync.maybeWhen(
              data: (apps) {
                final pageCount =
                    ((apps.take(16).length) / 8).ceil().clamp(1, 4);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageCount, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? theme.primary
                            : theme.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: _currentPage == i
                            ? [
                                BoxShadow(
                                  color: theme.glow.withOpacity(0.6),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Dock - terminal style
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: theme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primary.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withOpacity(0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DockBtn(
                    theme: theme,
                    icon: Icons.phone,
                    label: 'CALL',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final phone = apps
                          .where((a) =>
                              (a.packageName ?? '').contains('dialer') ||
                              (a.name ?? '')
                                  .toLowerCase()
                                  .contains('phone'))
                          .firstOrNull;
                      if (phone != null) _launch(phone);
                    },
                  ),
                  _DockBtn(
                    theme: theme,
                    icon: Icons.message,
                    label: 'MSG',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final sms = apps
                          .where((a) =>
                              (a.packageName ?? '').contains('mms') ||
                              (a.packageName ?? '').contains('messaging') ||
                              (a.name ?? '')
                                  .toLowerCase()
                                  .contains('message'))
                          .firstOrNull;
                      if (sms != null) _launch(sms);
                    },
                  ),
                  _DockBtn(
                    theme: theme,
                    icon: Icons.apps,
                    label: 'APPS',
                    onTap: _openDrawer,
                  ),
                  _DockBtn(
                    theme: theme,
                    icon: Icons.camera_alt,
                    label: 'CAM',
                    onTap: () async {
                      final apps = await ref.read(installedAppsProvider.future);
                      final cam = apps
                          .where((a) =>
                              (a.packageName ?? '').contains('camera') ||
                              (a.name ?? '').toLowerCase() == 'camera')
                          .firstOrNull;
                      if (cam != null) _launch(cam);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Swipe up
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 20,
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

class _HackerAppIcon extends StatelessWidget {
  final AppInfo app;
  final JagXThemeData theme;
  final VoidCallback onTap;

  const _HackerAppIcon({
    required this.app,
    required this.theme,
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withOpacity(0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: app.icon != null
                ? Image.memory(app.icon!, fit: BoxFit.cover)
                : Icon(Icons.terminal, color: theme.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            app.name ?? 'APP',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.shareTechMono(
              color: theme.text,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DockBtn extends StatelessWidget {
  final JagXThemeData theme;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DockBtn({
    required this.theme,
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
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.shareTechMono(
              color: theme.textDim,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
