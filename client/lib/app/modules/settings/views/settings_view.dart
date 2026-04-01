import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../widgets/ad_text.dart';
import 'instrument_selector_panel.dart';
import 'piano_settings_panel.dart';
import 'drum_settings_panel.dart';
import 'advanced_settings_panel.dart';
import 'calibration_panel.dart';

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
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InstrumentSelectorPanel(),
            const SizedBox(height: 32),
            Obx(() {
              final switching = controller.audioManager.isSwitching.value;
              final active = controller.audioManager.activeInstrumentName.value;

              if (switching) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (active == 'Piano') return const PianoSettingsPanel();
              if (active == 'Drums') return const DrumSettingsPanel();
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 32),
            AdText.label('ADVANCED PARAMETERS'),
            const SizedBox(height: 16),
            const AdvancedSettingsPanel(),
            const SizedBox(height: 32),
            AdText.label('HARDWARE / CALIBRATION'),
            const SizedBox(height: 16),
            const CalibrationPanel(),
          ],
        ),
      ),
    );
  }
}
