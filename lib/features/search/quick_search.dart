// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/services/app_service.dart';

class QuickSearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const QuickSearchOverlay({super.key, required this.onClose});

  @override
  ConsumerState<QuickSearchOverlay> createState() => _QuickSearchOverlayState();
}

class _QuickSearchOverlayState extends ConsumerState<QuickSearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _launch(AppInfo app) async {
    final ok = await launchApp(app.packageName ?? '');
    if (ok) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final appsAsync = ref.watch(installedAppsProvider);

    return Material(
      color: theme.background.withOpacity(0.96),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      onChanged: (v) => setState(() => _q = v),
                      style: GoogleFonts.shareTechMono(color: theme.text),
                      cursorColor: theme.primary,
                      decoration: InputDecoration(
                        hintText: '> search_apps...',
                        hintStyle: GoogleFonts.shareTechMono(
                          color: theme.textDim,
                        ),
                        prefixIcon: Icon(Icons.search, color: theme.primary),
                        filled: true,
                        fillColor: theme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: theme.primary.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: theme.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, color: theme.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: appsAsync.when(
                loading: () => Center(
                  child: Text(
                    'LOADING...',
                    style: GoogleFonts.shareTechMono(color: theme.primary),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (apps) {
                  final list = _q.isEmpty
                      ? apps.take(20).toList()
                      : apps
                          .where((a) => (a.name ?? '')
                              .toLowerCase()
                              .contains(_q.toLowerCase()))
                          .toList();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final app = list[i];
                      return ListTile(
                        leading: app.icon != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  app.icon!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.terminal, color: theme.primary),
                        title: Text(
                          app.name ?? 'APP',
                          style: GoogleFonts.shareTechMono(
                            color: theme.text,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          app.packageName ?? '',
                          style: GoogleFonts.shareTechMono(
                            color: theme.textDim,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _launch(app),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
