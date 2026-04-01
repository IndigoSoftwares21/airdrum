import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../widgets/ad_text.dart';

class InstrumentSelectorPanel extends GetView<SettingsController> {
  const InstrumentSelectorPanel({super.key});

  static const _meta = {
    'Piano': (Icons.piano, 'Select notes and octaves to trigger with each swing'),
    'Drums': (Icons.queue_music, 'Single sound or angle-mapped trigger selection'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.label('SELECT INSTRUMENT'),
        const SizedBox(height: 16),
        Obx(() {
          final active = controller.audioManager.activeInstrumentName.value;
          final switching = controller.audioManager.isSwitching.value;

          return Row(
            children: controller.availableInstruments.map((inst) {
              final isSelected = active == inst;
              final meta = _meta[inst]!;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _InstrumentCard(
                    label: inst,
                    icon: meta.$1,
                    description: meta.$2,
                    isSelected: isSelected,
                    isLoading: switching && !isSelected,
                    onTap: switching ? null : () => controller.switchInstrument(inst),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  const _InstrumentCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withOpacity(0.08)
            : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? cs.primary : cs.secondary,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : cs.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: cs.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 14),
                AdText.body(label, fontWeight: FontWeight.bold,
                    color: isSelected ? cs.onSurface : cs.onSurface.withOpacity(0.7)),
                const SizedBox(height: 4),
                AdText.label(description, color: cs.onSurface.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
