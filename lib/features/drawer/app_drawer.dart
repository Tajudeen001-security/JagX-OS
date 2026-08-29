// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        SnackBar(content: Text('Could not open ${app.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedAppsProvider);

    return Material(
      color: Colors.black.withOpacity(0.94),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'All Apps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search apps',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: appsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: JagXColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading apps\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
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
                    return const Center(
                      child: Text(
                        'No apps found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
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
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: app.icon != null
                                  ? Image.memory(app.icon!, fit: BoxFit.cover)
                                  : const Icon(Icons.android,
                                      color: Colors.white70, size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              app.name ?? 'App',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
