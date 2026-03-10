import 'package:get/get.dart';
import '../../../data/managers/audio_manager.dart';

class SettingsController extends GetxController {
  final AudioManager audioManager = Get.find<AudioManager>();

  // Currently available instruments in the app
  final List<String> availableInstruments = ['Piano', 'Drums'];

  void switchInstrument(String name) {
    if (audioManager.activeInstrumentName.value != name) {
      audioManager.switchToInstrument(name);
    }
  }

  final RxBool isDarkMode = true.obs;

  // Future global settings (dark mode, UDP port, IP config)
  final RxInt udpPort = 5000.obs;
  final RxDouble minIntensity = 5.0.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    // In the future this should trigger Get.changeThemeMode
  }
}
