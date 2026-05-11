import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/ad_text.dart';
import '../controllers/home_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/views/instrument_selector_panel.dart';
import '../../settings/views/piano_settings_panel.dart';
import '../../settings/views/drum_settings_panel.dart';
import '../../settings/views/advanced_settings_panel.dart';
import '../../settings/views/calibration_panel.dart';
import 'dashboard_panel.dart';
import 'sidebar_item.dart';
import '../../../widgets/ad_chip.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Unified Sidebar
          Container(
            width: 240,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                const SizedBox(height: 48),
                AdText.headline('Air Drum', fontWeight: FontWeight.bold),
                const SizedBox(height: 48),
                Obx(() => SidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: controller.selectedIndex.value == 0,
                  onTap: () => controller.selectedIndex.value = 0,
                )),
                Obx(() => SidebarItem(
                  icon: Icons.piano_rounded,
                  label: 'Instruments',
                  isActive: controller.selectedIndex.value == 1,
                  onTap: () => controller.selectedIndex.value = 1,
                )),
                 Obx(() => SidebarItem(
                   icon: Icons.bluetooth_searching_rounded,
                   label: 'Magic Setup',
                   isActive: controller.selectedIndex.value == 3,
                   onTap: () => Get.toNamed('/setup'),
                 )),
                 Obx(() => SidebarItem(
                   icon: Icons.settings_rounded,
                   label: 'Settings',
                   isActive: controller.selectedIndex.value == 2,
                   onTap: () => controller.selectedIndex.value = 2,
                 )),
                const Spacer(),
                _buildStatusFooter(context),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Switching
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: Obx(() {
                    switch (controller.selectedIndex.value) {
                      case 1:
                        return const _InstrumentTab();
                      case 2:
                        return const _SettingsTab();
                      case 0:
                      default:
                        return const DashboardPanel();
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => _TabTitle(controller.selectedIndex.value)),
          Row(
            children: [
              Obx(() => AdStatusChip(
                label: 'LEFT',
                isConnected: controller.leftConnected.value,
              )),
              const SizedBox(width: 8),
              Obx(() => AdStatusChip(
                label: 'RIGHT',
                isConnected: controller.rightConnected.value,
                isTrailing: true,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AdText.label(
        'v1.1.0',
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
      ),
    );
  }
}

class _TabTitle extends StatelessWidget {
  final int index;
  const _TabTitle(this.index);

  @override
  Widget build(BuildContext context) {
    String title = 'Dashboard';
    if (index == 1) title = 'Instruments';
    if (index == 2) title = 'General Settings';
    return AdText.headline(title, fontWeight: FontWeight.bold);
  }
}

class _InstrumentTab extends StatelessWidget {
  const _InstrumentTab();

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InstrumentSelectorPanel(),
          const SizedBox(height: 32),
          Obx(() {
            final switching = settingsController.audioManager.isSwitching.value;
            final active = settingsController.audioManager.activeInstrumentName.value;

            if (switching) {
              return const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(),
              ));
            }
            if (active == 'Piano') return const PianoSettingsPanel();
            if (active == 'Drums') return const DrumSettingsPanel();
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdText.label('HARDWARE CALIBRATION'),
          const SizedBox(height: 16),
          const CalibrationPanel(),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 48),
          AdText.label('NETWORK CONFIGURATION'),
          const SizedBox(height: 16),
          const AdvancedSettingsPanel(),
        ],
      ),
    );
  }
}
