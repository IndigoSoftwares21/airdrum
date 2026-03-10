import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../widgets/ad_text.dart';
import '../../../widgets/ad_button.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: AdText.title(
          'Settings',
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('GLOBAL SETTINGS'),
            const SizedBox(height: 16),
            _buildInstrumentSelector(context),
            const SizedBox(height: 32),
            _buildInstrumentSpecificSettings(context),
            const SizedBox(height: 32),
            _buildSectionHeader('ADVANCED PARAMETERS'),
            const SizedBox(height: 16),
            _buildAdvancedSettings(context),
            const SizedBox(height: 32),
            _buildSectionHeader('HARDWARE / CALIBRATION'),
            const SizedBox(height: 16),
            _buildCalibrationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AdText.label(title);
  }

  Widget _buildInstrumentSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdText.body('Active Instrument', fontWeight: FontWeight.w600),
          const SizedBox(height: 16),
          Obx(() {
            final activeInstrument =
                controller.audioManager.activeInstrumentName.value;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.availableInstruments.map((inst) {
                final isSelected = activeInstrument == inst;
                return ChoiceChip(
                  label: AdText.body(
                    inst,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (selected) {
                    if (selected) controller.switchInstrument(inst);
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInstrumentSpecificSettings(BuildContext context) {
    return Obx(() {
      final activeInstrument =
          controller.audioManager.activeInstrumentName.value;
      if (activeInstrument == 'Piano') {
        return _buildPianoSettings(context);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildPianoSettings(BuildContext context) {
    final pianoHandler =
        controller.audioManager.currentInstrument
            as dynamic; // Cast to dynamic as it's known at runtime
    if (pianoHandler == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PIANO CONFIGURATION'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOctaveSelector(
                context,
                'LEFT HAND OCTAVE (BASS)',
                pianoHandler.leftOctave,
                pianoHandler.setLeftOctave,
              ),
              const SizedBox(height: 32),
              _buildOctaveSelector(
                context,
                'RIGHT HAND OCTAVE (MELODY)',
                pianoHandler.rightOctave,
                pianoHandler.setRightOctave,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOctaveSelector(
    BuildContext context,
    String label,
    RxInt rxValue,
    Function(int) setter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdText.body(label, fontWeight: FontWeight.w600),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(5, (index) {
            final octave = index + 1;
            return Obx(() {
              final isSelected = rxValue.value == octave;
              return ChoiceChip(
                label: AdText.label(
                  'Oct $octave',
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primary,
                onSelected: (selected) {
                  if (selected) setter(octave);
                },
              );
            });
          }),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdText.body('UDP Port', fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AdText.body(
            'The port to listen for incoming stick connections. Requires restart to apply.',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 150,
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: controller.udpPort.value.toString(),
              ),
              onSubmitted: (value) {
                if (int.tryParse(value) != null) {
                  controller.udpPort.value = int.parse(value);
                  Get.snackbar(
                    'Saved',
                    'Restart the app to bind to Port ${controller.udpPort.value}',
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          AdText.body(
            'Minimum Hit Intensity (Sensitivity)',
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          AdText.body(
            'Lower values are more sensitive and might trigger accidental notes.',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          Obx(
            () => Slider(
              value: controller.minIntensity.value,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              label: controller.minIntensity.value.toStringAsFixed(1),
              onChanged: (val) => controller.minIntensity.value = val,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdText.body('Recalibrate Center', fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AdText.body(
            'Point both sticks straight ahead and click recalibrate to reset the 0° position.',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          AdButton.filled(
            label: 'RECALIBRATE NOW',
            onPressed: () {
              // Future: Send UDP packet back to ESP32s or handle offset locally
              Get.snackbar(
                'Recalibrated',
                'Center position has been reset.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).colorScheme.primary,
                colorText: Theme.of(context).colorScheme.onPrimary,
                margin: const EdgeInsets.all(24),
              );
            },
          ),
        ],
      ),
    );
  }
}
