// JRILICENSE
// Copyright (c) 2026 JagX OS Contributors
// JagX Control Center — not iOS, not Android stock. Fully JagX.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jagx_os/core/theme/jagx_theme.dart';

/// Default tile order — unique JagX set
const _defaultOrder = [
  'wifi',
  'bt',
  'data',
  'airplane',
  'torch',
  'dnd',
  'rotate',
  'location',
  'hotspot',
  'saver',
  'mute',
  'cast',
];

class CcTileDef {
  final String id;
  final String label;
  final IconData icon;
  final IconData iconOff;

  const CcTileDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconOff,
  });
}

const _catalog = <String, CcTileDef>{
  'wifi': CcTileDef(id: 'wifi', label: 'LINK', icon: Icons.wifi, iconOff: Icons.wifi_off),
  'bt': CcTileDef(id: 'bt', label: 'BT', icon: Icons.bluetooth, iconOff: Icons.bluetooth_disabled),
  'data': CcTileDef(id: 'data', label: 'DATA', icon: Icons.signal_cellular_alt, iconOff: Icons.signal_cellular_nodata),
  'airplane': CcTileDef(id: 'airplane', label: 'AIR', icon: Icons.airplanemode_active, iconOff: Icons.airplanemode_inactive),
  'torch': CcTileDef(id: 'torch', label: 'BEAM', icon: Icons.flashlight_on, iconOff: Icons.flashlight_off),
  'dnd': CcTileDef(id: 'dnd', label: 'SILENT', icon: Icons.do_not_disturb_on, iconOff: Icons.do_not_disturb_off),
  'rotate': CcTileDef(id: 'rotate', label: 'SPIN', icon: Icons.screen_rotation, iconOff: Icons.screen_lock_rotation),
  'location': CcTileDef(id: 'location', label: 'GEO', icon: Icons.location_on, iconOff: Icons.location_off),
  'hotspot': CcTileDef(id: 'hotspot', label: 'SHARE', icon: Icons.wifi_tethering, iconOff: Icons.wifi_tethering_off),
  'saver': CcTileDef(id: 'saver', label: 'POWER', icon: Icons.battery_saver, iconOff: Icons.battery_std),
  'mute': CcTileDef(id: 'mute', label: 'MUTE', icon: Icons.volume_off, iconOff: Icons.volume_up),
  'cast': CcTileDef(id: 'cast', label: 'CAST', icon: Icons.cast, iconOff: Icons.cast_connected),
};

class ControlCenterState {
  final List<String> order;
  final Map<String, bool> active;
  final double brightness;
  final double volume;
  final bool editMode;
  final bool islandExpanded;

  ControlCenterState({
    required this.order,
    required this.active,
    required this.brightness,
    required this.volume,
    required this.editMode,
    required this.islandExpanded,
  });

  ControlCenterState copyWith({
    List<String>? order,
    Map<String, bool>? active,
    double? brightness,
    double? volume,
    bool? editMode,
    bool? islandExpanded,
  }) {
    return ControlCenterState(
      order: order ?? this.order,
      active: active ?? this.active,
      brightness: brightness ?? this.brightness,
      volume: volume ?? this.volume,
      editMode: editMode ?? this.editMode,
      islandExpanded: islandExpanded ?? this.islandExpanded,
    );
  }
}

class ControlCenterNotifier extends StateNotifier<ControlCenterState> {
  ControlCenterNotifier() : super(_initial()) {
    _load();
  }

  static ControlCenterState _initial() {
    final active = {for (final id in _defaultOrder) id: false};
    active['wifi'] = true;
    return ControlCenterState(
      order: List.from(_defaultOrder),
      active: active,
      brightness: 0.7,
      volume: 0.5,
      editMode: false,
      islandExpanded: false,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('jagx_cc_order');
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<String>();
        if (list.isNotEmpty) {
          state = state.copyWith(order: list);
        }
      } catch (_) {}
    }
    final bright = prefs.getDouble('jagx_cc_bright');
    final vol = prefs.getDouble('jagx_cc_vol');
    if (bright != null || vol != null) {
      state = state.copyWith(
        brightness: bright ?? state.brightness,
        volume: vol ?? state.volume,
      );
    }
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jagx_cc_order', jsonEncode(state.order));
  }

  Future<void> _saveSliders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('jagx_cc_bright', state.brightness);
    await prefs.setDouble('jagx_cc_vol', state.volume);
  }

  void toggle(String id) {
    final next = Map<String, bool>.from(state.active);
    next[id] = !(next[id] ?? false);
    state = state.copyWith(active: next);
    HapticFeedback.selectionClick();
  }

  void setBrightness(double v) {
    state = state.copyWith(brightness: v.clamp(0.0, 1.0));
    _saveSliders();
  }

  void setVolume(double v) {
    state = state.copyWith(volume: v.clamp(0.0, 1.0));
    _saveSliders();
  }

  void setEditMode(bool v) {
    state = state.copyWith(editMode: v);
  }

  void reorder(int oldIndex, int newIndex) {
    final list = List<String>.from(state.order);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(order: list);
    _saveOrder();
  }

  Future<void> reset() async {
    state = _initial().copyWith(
      brightness: state.brightness,
      volume: state.volume,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jagx_cc_order');
    HapticFeedback.mediumImpact();
  }

  void toggleIsland() {
    state = state.copyWith(islandExpanded: !state.islandExpanded);
  }
}

final controlCenterProvider =
    StateNotifierProvider<ControlCenterNotifier, ControlCenterState>((ref) {
  return ControlCenterNotifier();
});

/// Full-screen Control Center overlay
class JagXControlCenter extends ConsumerWidget {
  final VoidCallback onClose;

  const JagXControlCenter({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final cc = ref.watch(controlCenterProvider);
    final notifier = ref.read(controlCenterProvider.notifier);

    return Material(
      color: Colors.black.withOpacity(0.55),
      child: SafeArea(
        child: Column(
          children: [
            // Drag handle / dismiss
            GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! < -200) {
                  onClose();
                }
              },
              onTap: onClose,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // === DYNAMIC ISLAND (JagX style) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: GestureDetector(
                onTap: notifier.toggleIsland,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  width: cc.islandExpanded ? double.infinity : 140,
                  height: cc.islandExpanded ? 72 : 36,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(
                      cc.islandExpanded ? 24 : 20,
                    ),
                    border: Border.all(
                      color: theme.primary.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.glow.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: cc.islandExpanded
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.glow,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'JAGX  ·  CORE ACTIVE',
                                style: GoogleFonts.shareTechMono(
                                  color: theme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'JAGX',
                            style: GoogleFonts.shareTechMono(
                              color: theme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
              child: Row(
                children: [
                  Text(
                    '> CONTROL_NODE',
                    style: GoogleFonts.shareTechMono(
                      color: theme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  if (cc.editMode)
                    TextButton(
                      onPressed: () => notifier.reset(),
                      child: Text(
                        'RESET',
                        style: GoogleFonts.shareTechMono(
                          color: theme.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => notifier.setEditMode(!cc.editMode),
                    child: Text(
                      cc.editMode ? 'DONE' : 'MOVE',
                      style: GoogleFonts.shareTechMono(
                        color: theme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.primary, size: 22),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            if (cc.editMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Hold & drag tiles to rearrange · RESET restores default',
                  style: GoogleFonts.shareTechMono(
                    color: theme.textDim,
                    fontSize: 10,
                  ),
                ),
              ),

            // Tiles
            Expanded(
              child: cc.editMode
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cc.order.length,
                      onReorder: notifier.reorder,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 8,
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final id = cc.order[index];
                        final def = _catalog[id]!;
                        final on = cc.active[id] ?? false;
                        return _EditTile(
                          key: ValueKey(id),
                          theme: theme,
                          def: def,
                          active: on,
                          index: index,
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: cc.order.length,
                      itemBuilder: (context, i) {
                        final id = cc.order[i];
                        final def = _catalog[id]!;
                        final on = cc.active[id] ?? false;
                        return _CcTile(
                          theme: theme,
                          def: def,
                          active: on,
                          onTap: () => notifier.toggle(id),
                        );
                      },
                    ),
            ),

            // Sliders — JagX style vertical-ish bars in a row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _JagXSlider(
                      theme: theme,
                      icon: Icons.brightness_6,
                      label: 'LIGHT',
                      value: cc.brightness,
                      onChanged: notifier.setBrightness,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _JagXSlider(
                      theme: theme,
                      icon: Icons.volume_up,
                      label: 'AUDIO',
                      value: cc.volume,
                      onChanged: notifier.setVolume,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Swipe up to close · MOVE to rearrange',
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

class _CcTile extends StatelessWidget {
  final JagXThemeData theme;
  final CcTileDef def;
  final bool active;
  final VoidCallback onTap;

  const _CcTile({
    required this.theme,
    required this.def,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active ? theme.primary.withOpacity(0.2) : theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? theme.primary : theme.primary.withOpacity(0.25),
            width: active ? 1.5 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: theme.glow.withOpacity(0.35),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? def.icon : def.iconOff,
              color: theme.primary,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              def.label,
              style: GoogleFonts.shareTechMono(
                color: active ? theme.primary : theme.textDim,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  final JagXThemeData theme;
  final CcTileDef def;
  final bool active;
  final int index;

  const _EditTile({
    super.key,
    required this.theme,
    required this.def,
    required this.active,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_handle, color: theme.primary.withOpacity(0.6)),
          const SizedBox(width: 12),
          Icon(def.icon, color: theme.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            def.label,
            style: GoogleFonts.shareTechMono(
              color: theme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '#${index + 1}',
            style: GoogleFonts.shareTechMono(
              color: theme.textDim,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _JagXSlider extends StatelessWidget {
  final JagXThemeData theme;
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _JagXSlider({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.shareTechMono(
                  color: theme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: GoogleFonts.shareTechMono(
                  color: theme.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.primary,
              inactiveTrackColor: theme.primary.withOpacity(0.2),
              thumbColor: theme.primary,
              overlayColor: theme.glow.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
