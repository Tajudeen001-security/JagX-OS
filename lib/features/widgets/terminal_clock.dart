// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

class TerminalClock extends ConsumerStatefulWidget {
  const TerminalClock({super.key});

  @override
  ConsumerState<TerminalClock> createState() => _TerminalClockState();
}

class _TerminalClockState extends ConsumerState<TerminalClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final time = DateFormat('HH:mm:ss').format(_now);
    final date = DateFormat('EEE dd MMM yyyy').format(_now).toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: theme.glow.withOpacity(0.12), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: GoogleFonts.shareTechMono(
                  color: theme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.shareTechMono(
                  color: theme.textDim,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SYS_ONLINE',
                style: GoogleFonts.shareTechMono(
                  color: theme.primary,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'JAGX_CORE',
                style: GoogleFonts.shareTechMono(
                  color: theme.textDim,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
