// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/services/app_service.dart';

class SystemPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const SystemPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final appsAsync = ref.watch(installedAppsProvider);

    return Material(
      color: theme.background.withOpacity(0.97),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Text(
                    '> SYSTEM_TERMINAL',
                    style: GoogleFonts.shareTechMono(
                      color: theme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.primary),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.primary.withOpacity(0.35)),
                ),
                child: appsAsync.when(
                  loading: () => Text(
                    'booting...\nscanning packages...',
                    style: GoogleFonts.shareTechMono(
                      color: theme.primary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  error: (e, _) => Text(
                    'ERR :: $e',
                    style: GoogleFonts.shareTechMono(color: theme.danger),
                  ),
                  data: (apps) {
                    final lines = [
                      'JAGX OS v1.2  //  JRILICENSE',
                      'theme       : ${theme.name}',
                      'packages    : ${apps.length}',
                      'status      : ONLINE',
                      'launcher    : ACTIVE',
                      'shell       : HOME_SHELL',
                      '--------------------------------',
                      'cmds: search | cfg | apps | exit',
                      '',
                      'root@jagx:~# _',
                    ];
                    return SingleChildScrollView(
                      child: Text(
                        lines.join('\n'),
                        style: GoogleFonts.shareTechMono(
                          color: theme.primary,
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Long-press any app for options · Pull search from CFG',
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: theme.textDim,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
