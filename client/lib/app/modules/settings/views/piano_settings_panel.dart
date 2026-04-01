import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../data/services/instruments/air_piano_handler.dart';
import '../../../widgets/ad_text.dart';

class PianoSettingsPanel extends GetView<SettingsController> {
  const PianoSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final handler = controller.audioManager.currentInstrument as AirPianoHandler?;
    if (handler == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.label('PIANO CONFIGURATION'),
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
              _HandSection(
                label: 'LEFT HAND CONFIGURATION',
                octaveValue: handler.leftOctave,
                noteValue: handler.selectedLeftNote,
                onOctaveChanged: handler.setLeftOctave,
                cs: cs,
              ),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 48),
              _HandSection(
                label: 'RIGHT HAND CONFIGURATION',
                octaveValue: handler.rightOctave,
                noteValue: handler.selectedRightNote,
                onOctaveChanged: handler.setRightOctave,
                cs: cs,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HandSection extends StatelessWidget {
  final String label;
  final RxInt octaveValue;
  final RxString noteValue;
  final Function(int) onOctaveChanged;
  final ColorScheme cs;

  const _HandSection({
    required this.label,
    required this.octaveValue,
    required this.noteValue,
    required this.onOctaveChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.body(label, fontWeight: FontWeight.bold, color: cs.primary),
        const SizedBox(height: 24),
        AdText.label('Octave', fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          children: List.generate(5, (i) {
            final octave = i + 1;
            final isSelected = octaveValue.value == octave;
            return ChoiceChip(
              label: Text('OCT $octave'),
              selected: isSelected,
              onSelected: (s) { if (s) onOctaveChanged(octave); },
            );
          }),
        )),
        const SizedBox(height: 24),
        AdText.label('Specific Note', fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          children: ['C', 'D', 'E', 'F', 'G', 'A', 'B'].map((note) {
            final isSelected = noteValue.value == note;
            return ChoiceChip(
              label: Text(note),
              selected: isSelected,
              onSelected: (s) { if (s) noteValue.value = note; },
            );
          }).toList(),
        )),
      ],
    );
  }
}
