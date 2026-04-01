import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../widgets/ad_text.dart';

class AdvancedSettingsPanel extends GetView<SettingsController> {
  const AdvancedSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: cs.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdText.body('UDP Network Port', fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AdText.label(
            'The port to listen for incoming stick connections. Requires restart to apply.',
            color: cs.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            child: TextField(
              style: TextStyle(color: cs.onSurface, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: cs.secondary.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    backgroundColor: cs.primary,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 48),
          AdText.body('Minimum Hit Intensity (Sensitivity)', fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AdText.label(
            'Lower values make the sticks more sensitive to light movements.',
            color: cs.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
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
}
