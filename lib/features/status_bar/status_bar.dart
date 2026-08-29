// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Minimal status bar for JagX OS.
/// Decision: pure Flutter for now. Later we can mirror real system status via
/// platform channels. Keeping it lightweight avoids battery drain.
class JagXStatusBar extends StatelessWidget {
  const JagXStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            const Icon(Icons.wifi, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            const Icon(Icons.battery_full, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
