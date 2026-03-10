import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/data/services/udp_service.dart';
import 'app/data/managers/audio_manager.dart';
import 'app/modules/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Global Services
  Get.put(SettingsController());
  Get.put(UdpService());
  Get.put(AudioManager());

  runApp(
    GetMaterialApp(
      title: "Air Drum",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(
          0xFF1E1E2E,
        ), // Modern dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'monospace'),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
