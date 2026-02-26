import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/ad_text.dart';
import '../../../widgets/ad_chip.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail following M3 guidelines
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              // Future: Handle navigation for settings/sound engine tweaks
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: Text('Logs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(child: _buildLogPanel(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AdText.headline('AirDrum Monitor'),
          Row(
            children: [
              _buildConnectionStatus(context, 'LEFT', controller.leftConnected),
              const SizedBox(width: 16),
              _buildConnectionStatus(
                context,
                'RIGHT',
                controller.rightConnected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    String label,
    RxBool isConnected,
  ) {
    return Obx(() {
      return AdStatusChip(label: label, isConnected: isConnected.value);
    });
  }

  Widget _buildLogPanel(BuildContext context) {
    return Obx(() {
      if (controller.logs.isEmpty) {
        return Center(
          child: AdText.body(
            'Waiting for UDP logs on port 5000...',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }

      return ListView.builder(
        reverse:
            true, // Keeps panel scrolled to the bottom while adding new items
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.logs.length,
        itemBuilder: (context, index) {
          // Because of reverse: true, we want the most recent log at index 0
          int logIndex = controller.logs.length - 1 - index;
          final log = controller.logs[logIndex];

          return _buildLogItem(context, log);
        },
      );
    });
  }

  Widget _buildLogItem(BuildContext context, String log) {
    final bool isHit = log.contains('HIT');
    final bool isLeft = log.contains('[LEFT]');
    final bool isRight = log.contains('[RIGHT]');

    Color? textColor = Theme.of(context).colorScheme.onSurface;
    if (isHit) {
      textColor = Theme.of(context).colorScheme.primary;
    } else if (isLeft) {
      textColor = Theme.of(context).colorScheme.tertiary;
    } else if (isRight) {
      textColor = Theme.of(context).colorScheme.secondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHit
                ? Icons.data_usage
                : (isLeft ? Icons.sports_tennis : Icons.sports_baseball),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AdText.monospace(
              log,
              color: textColor,
              fontWeight: isHit ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
