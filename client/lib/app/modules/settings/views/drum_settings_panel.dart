import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../data/services/instruments/air_drum_handler.dart';
import '../../../widgets/ad_text.dart';

class DrumSettingsPanel extends GetView<SettingsController> {
  const DrumSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final handler = controller.audioManager.currentInstrument as AirDrumHandler?;
    if (handler == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.label('DRUM CONFIGURATION'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: cs.secondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StickSection(
                label: 'LEFT STICK CONFIGURATION',
                voiceValue: handler.selectedLeftVoice,
                cs: cs,
              ),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 48),
              _StickSection(
                label: 'RIGHT STICK CONFIGURATION',
                voiceValue: handler.selectedRightVoice,
                cs: cs,
              ),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 48),
              _KitSection(handler: handler),
            ],
          ),
        ),
      ],
    );
  }
}

class _StickSection extends StatelessWidget {
  final String label;
  final RxString voiceValue;
  final ColorScheme cs;

  const _StickSection({
    required this.label,
    required this.voiceValue,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    const voices = ['bass', 'snare', 'tom', 'crash'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.body(label, fontWeight: FontWeight.bold, color: cs.primary),
        const SizedBox(height: 24),
        AdText.label('Specific Drum Voice', fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          children: voices.map((v) {
            final isSelected = voiceValue.value == v;
            return ChoiceChip(
              label: Text(v.toUpperCase()),
              selected: isSelected,
              onSelected: (s) { if (s) voiceValue.value = v; },
            );
          }).toList(),
        )),
      ],
    );
  }
}

class _KitSection extends StatelessWidget {
  final AirDrumHandler handler;

  const _KitSection({required this.handler});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.body('KIT SELECTION', fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Obx(() {
          final currentKit = handler.selectedKit.value;
          return Wrap(
            spacing: 12,
            children: AirDrumHandler.availableKits.map((kit) {
              final isSelected = currentKit == kit;
              return ChoiceChip(
                label: Text(kit.toUpperCase()),
                selected: isSelected,
                onSelected: (s) { if (s) handler.setKit(kit); },
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
