// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';
import 'package:jagx_os/core/services/app_service.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const AppDrawer({super.key, required this.onClose});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _launch(AppInfo app) async {
    final ok = await launchApp(app.packageName ?? '');
    if (ok) {
      widget.onClose();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAILED :: ${app.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final appsAsync = ref.watch(installedAppsProvider);

    return Material(
      color: theme.background.withOpacity(0.97),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    '> APP_REGISTRY',
                    style: GoogleFonts.shareTechMono(
                      color: theme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.primary),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.shareTechMono(color: theme.text),
                cursorColor: theme.primary,
                decoration: InputDecoration(
                  hintText: 'search_package...',
                  hintStyle: GoogleFonts.shareTechMono(
                    color: theme.textDim,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.terminal, color: theme.primary),
                  filled: true,
                  fillColor: theme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primary.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
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
                error: (e, _) => Center(
                  child: Text(
                    'ERR :: $e',
                    style: GoogleFonts.shareTechMono(color: theme.danger),
                  ),
                ),
                data: (apps) {
                  final filtered = _query.isEmpty
                      ? apps
                      : apps
                          .where((a) => (a.name ?? '')
                              .toLowerCase()
                              .contains(_query.toLowerCase()))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'NO_MATCH',
                        style: GoogleFonts.shareTechMono(color: theme.textDim),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final app = filtered[i];
                      return GestureDetector(
                        onTap: () => _launch(app),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.3),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: app.icon != null
                                  ? Image.memory(app.icon!, fit: BoxFit.cover)
                                  : Icon(Icons.terminal,
                                      color: theme.primary, size: 26),
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
