// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);
    final date = DateFormat('EEE, MMM d').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              time,
              style: GoogleFonts.shareTechMono(
                color: theme.primary,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: GoogleFonts.shareTechMono(
                color: theme.textDim,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '> LOCKED',
              style: GoogleFonts.shareTechMono(
                color: theme.primary.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 4,
              ),
            ),
            const Spacer(flex: 3),
            Text(
              'SWIPE UP TO UNLOCK',
              style: GoogleFonts.shareTechMono(
                color: theme.textDim,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
