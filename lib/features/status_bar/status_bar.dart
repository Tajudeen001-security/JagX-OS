// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class JagXStatusBar extends ConsumerWidget {
  const JagXStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final now = DateTime.now();
    final time = DateFormat('HH:mm:ss').format(now);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              'JAGX',
              style: GoogleFonts.shareTechMono(
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withOpacity(0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              time,
              style: GoogleFonts.shareTechMono(
                color: theme.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.signal_cellular_alt, color: theme.primary, size: 14),
            const SizedBox(width: 4),
            Icon(Icons.wifi, color: theme.primary, size: 14),
            const SizedBox(width: 4),
            Icon(Icons.battery_full, color: theme.primary, size: 14),
          ],
        ),
      ),
    );
  }
}
