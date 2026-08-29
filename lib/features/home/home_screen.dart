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
import 'package:jagx_os/features/widgets/terminal_clock.dart';
import 'package:jagx_os/features/search/quick_search.dart';
import 'package:jagx_os/features/system/system_panel.dart';
import 'package:jagx_os/features/control_center/control_center.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showDrawer = false;
  bool _showSearch = false;
  bool _showSystem = false;
  bool _showCC = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() => setState(() => _showDrawer = true);
  void _closeDrawer() => setState(() => _showDrawer = false);
  void _openCC() => setState(() => _showCC = true);
  void _closeCC() => setState(() => _showCC = false);

  Future<void> _launch(AppInfo app) async {
    final ok = await launchApp(app.packageName ?? '');
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FAILED :: ${app.name}'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  void _showAppMenu(AppInfo app, JagXThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (app.icon != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(app.icon!, width: 40, height: 40),
                    )
                  else
                    Icon(Icons.terminal, color: theme.primary, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name ?? 'APP',
                          style: GoogleFonts.shareTechMono(
                            color: theme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          app.packageName ?? '',
                          style: GoogleFonts.shareTechMono(
                            color: theme.textDim,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MenuBtn(
                theme: theme,
                icon: Icons.play_arrow,
                label: 'LAUNCH',
                onTap: () {
                  Navigator.pop(ctx);
                  _launch(app);
                },
              ),
              const SizedBox(height: 8),
              _MenuBtn(
                theme: theme,
                icon: Icons.info_outline,
                label: 'PACKAGE_INFO',
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${app.name}\n${app.packageName}\nv${app.versionName ?? '?'}',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final appsAsync = ref.watch(installedAppsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
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

          // Swipe down from top edge → Control Center
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 48,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! > 250) {
                  _openCC();
                }
              },
              child: const JagXStatusBar(),
            ),
          ),

          // Header
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Text(
                  '> HOME_SHELL',
                  style: GoogleFonts.shareTechMono(
                    color: theme.primary,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                appsAsync.maybeWhen(
                  data: (apps) => Text(
                    '[${apps.length}]',
                    style: GoogleFonts.shareTechMono(
                      color: theme.textDim,
                      fontSize: 11,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const Spacer(),
                _ChipBtn(
                  theme: theme,
                  label: 'CC',
                  onTap: _openCC,
                ),
                const SizedBox(width: 6),
                _ChipBtn(
                  theme: theme,
                  label: 'SYS',
                  onTap: () => setState(() => _showSystem = true),
                ),
                const SizedBox(width: 6),
                _ChipBtn(
                  theme: theme,
                  label: 'FIND',
                  onTap: () => setState(() => _showSearch = true),
                ),
                const SizedBox(width: 6),
                _ChipBtn(
                  theme: theme,
                  label: 'CFG',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Positioned(
            top: 78,
            left: 0,
            right: 0,
            child: TerminalClock(),
          ),

          Positioned.fill(
            top: 160,
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: pageApps.length,
                      itemBuilder: (context, i) {
                        final app = pageApps[i];
                        return _HackerAppIcon(
                          app: app,
                          theme: theme,
                          onTap: () => _launch(app),
                          onLongPress: () => _showAppMenu(app, theme),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

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
                      ),
                    );
                  }),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

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
                    icon: Icons.tune,
                    label: 'CC',
                    onTap: _openCC,
                  ),
                ],
              ),
            ),
          ),

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
            Positioned.fill(child: AppDrawer(onClose: _closeDrawer)),

          if (_showSearch)
            Positioned.fill(
              child: QuickSearchOverlay(
                onClose: () => setState(() => _showSearch = false),
              ),
            ),

          if (_showSystem)
            Positioned.fill(
              child: SystemPanel(
                onClose: () => setState(() => _showSystem = false),
              ),
            ),

          if (_showCC)
            Positioned.fill(
              child: JagXControlCenter(onClose: _closeCC),
            ),
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  final JagXThemeData theme;
  final String label;
  final VoidCallback onTap;

  const _ChipBtn({
    required this.theme,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.primary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: theme.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MenuBtn extends StatelessWidget {
  final JagXThemeData theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuBtn({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: theme.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.shareTechMono(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HackerAppIcon extends StatelessWidget {
  final AppInfo app;
  final JagXThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HackerAppIcon({
    required this.app,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
