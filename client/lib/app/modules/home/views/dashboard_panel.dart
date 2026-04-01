import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../widgets/ad_text.dart';
import '../../../data/managers/audio_manager.dart';

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final AudioManager audioManager = Get.find<AudioManager>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildMainVisualizer(context, controller, audioManager),
        ),
      ],
    );
  }

  Widget _buildMainVisualizer(
    BuildContext context,
    HomeController controller,
    AudioManager audioManager,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AdText.label(
              'SWING TO PLAY',
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 64),
            // Live Hit Visualizer
            Obx(() {
              final hitEvent = controller.lastHitEvent.value;
              if (hitEvent == null) {
                return _buildEmptyVisual();
              }

              return TweenAnimationBuilder<double>(
                key: ValueKey(hitEvent.hashCode),
                tween: Tween(begin: 1.0, end: 0.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Glowing Ring
                      Container(
                        width: 180 + (40 * value),
                        height: 180 + (40 * value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3 * value),
                            width: 2,
                          ),
                        ),
                      ),
                      // Core Circle
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(value),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2 * value),
                              blurRadius: 20 * value,
                              spreadRadius: 2 * value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AdText.headline(
                                hitEvent.deviceId,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: 4),
                              AdText.label(
                                'PEAK: ${hitEvent.peak.toStringAsFixed(0)}',
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisual() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.sensors, size: 64, color: Colors.grey),
      ),
    );
  }
}
