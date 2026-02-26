import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/data/services/udp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Global Services
  Get.put(UdpService());

  runApp(
    GetMaterialApp(
      title: "AirDrum Studio",
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
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
