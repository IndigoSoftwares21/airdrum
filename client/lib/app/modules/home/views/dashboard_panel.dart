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
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AdText.label(
              'SWING TO PLAY',
              fontWeight: FontWeight.w400,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 48),
            // Live Hit Visualizer
            Obx(() {
              final hitEvent = controller.lastHitEvent.value;
              if (hitEvent == null) {
                return _buildEmptyVisual();
              }

              return TweenAnimationBuilder<double>(
                key: ValueKey(hitEvent.hashCode), // Re-trigger on new hit
                tween: Tween(begin: 1.0, end: 0.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuad,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * (hitEvent.peak / 127.0) * 0.5),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5 * value),
                              blurRadius: 40 * value,
                              spreadRadius: 20 * value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AdText.headline(
                                hitEvent.deviceId,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              AdText.label(
                                'Peak: ${hitEvent.peak.toStringAsFixed(0)}',
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
