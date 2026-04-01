import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/data/services/udp_service.dart';
import 'app/data/managers/audio_manager.dart';
import 'app/modules/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AudioManager());
  Get.put(SettingsController());
  Get.put(UdpService());

  runApp(
    GetMaterialApp(
      title: "Air Drum",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // macOS dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6), // Teal accent
          brightness: Brightness.dark,
          surface: const Color(0xFF2C2C2E), // macOS surface gray
          onSurface: const Color(0xFFFAFAFA),
          secondary: const Color(0xFF3A3A3C), // macOS secondary gray
          primary: const Color(0xFF14B8A6),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'SF Pro Display', // Prefer SF Pro if available
          bodyColor: const Color(0xFFFAFAFA),
          displayColor: const Color(0xFFFAFAFA),
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: const Color(0x0AFFFFFF),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3A3A3C),
          thickness: 1,
          space: 1,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2C2C2E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF3A3A3C)),
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF1C1C1E),
          selectedIconTheme: IconThemeData(color: Color(0xFF14B8A6)),
          unselectedIconTheme: IconThemeData(color: Color(0xFF8E8E93)),
          selectedLabelTextStyle: TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.w600),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFF8E8E93)),
          indicatorColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF14B8A6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            splashFactory: NoSplash.splashFactory,
            enableFeedback: false,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withOpacity(0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              return null;
            }),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: Color(0xFF3A3A3C)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            splashFactory: NoSplash.splashFactory,
            enableFeedback: false,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withOpacity(0.04);
              }
              return null;
            }),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            splashFactory: NoSplash.splashFactory,
            enableFeedback: false,
            foregroundColor: const Color(0xFF14B8A6),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
