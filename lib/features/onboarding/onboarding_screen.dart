// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/features/home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.terminal,
      title: 'JAGX OS',
      body: 'Custom launcher shell. Not a normal home screen.',
    ),
    _OnboardPage(
      icon: Icons.apps,
      title: 'FULL APP ACCESS',
      body: 'Reads and launches every app installed on this device.',
    ),
    _OnboardPage(
      icon: Icons.palette,
      title: 'THEME PROTOCOLS',
      body: 'MATRIX, CYBERPUNK, GHOST, BLOOD, OCEAN, AMBER. Switch anytime in CFG.',
    ),
    _OnboardPage(
      icon: Icons.home_filled,
      title: 'SET AS DEFAULT',
      body: 'Tap below, then choose JagX OS as your Home app. Press Home after.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _openHomeSettings().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? theme.primary : theme.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _page == _pages.length - 1
                        ? 'SET AS DEFAULT LAUNCHER'
                        : 'CONTINUE',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: Text(
                'SKIP',
                style: GoogleFonts.shareTechMono(
                  color: theme.textDim,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: theme.primary.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(icon, size: 44, color: theme.primary),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              fontSize: 14,
              color: theme.textDim,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
