import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/ad_text.dart';
import '../../../widgets/ad_chip.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'dashboard_panel.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail following M3 guidelines
          Obx(
            () => NavigationRail(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (int index) {
                if (index == 1) {
                  Get.toNamed(Routes.SETTINGS);
                  // Don't update selectedIndex locally so it bounces back to Home
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                const Expanded(child: DashboardPanel()),
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
          _buildConnectionStatus(
            context,
            'LEFT',
            controller.leftConnected,
            isTrailing: false,
          ),
          AdText.headline('Air Drum', fontWeight: FontWeight.bold),
          _buildConnectionStatus(
            context,
            'RIGHT',
            controller.rightConnected,
            isTrailing: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    String label,
    RxBool isConnected, {
    bool isTrailing = false,
  }) {
    return Obx(() {
      return AdStatusChip(
        label: label,
        isConnected: isConnected.value,
        isTrailing: isTrailing,
      );
    });
  }
}
