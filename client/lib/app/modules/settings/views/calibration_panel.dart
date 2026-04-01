import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/ad_text.dart';
import '../../../widgets/ad_button.dart';

class CalibrationPanel extends StatelessWidget {
  const CalibrationPanel({super.key});

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
          AdText.body('Recalibrate Center', fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AdText.label(
            'Point both sticks straight ahead and click recalibrate to reset the 0 position.',
            color: cs.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          AdButton.filled(
            label: 'RECALIBRATE NOW',
            onPressed: () {
              Get.snackbar(
                'Recalibrated',
                'Center position has been reset.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: cs.primary,
                colorText: cs.onPrimary,
                margin: const EdgeInsets.all(24),
              );
            },
          ),
        ],
      ),
    );
  }
}
