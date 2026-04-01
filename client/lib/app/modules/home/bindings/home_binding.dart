import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingsController>(SettingsController());
    Get.put<HomeController>(HomeController());
  }
}
