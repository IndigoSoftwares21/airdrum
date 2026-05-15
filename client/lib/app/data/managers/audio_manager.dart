import 'package:get/get.dart';

import '../interfaces/instrument_handler.dart';
import '../services/instruments/air_piano_handler.dart';
import '../services/instruments/air_drum_handler.dart';
import '../models/hit_event.dart';
import '../../utils/logger.dart';

class AudioManager extends GetxService {
  InstrumentHandler? _activeInstrument;
  final RxString activeInstrumentName = ''.obs;
  final RxBool isSwitching = false.obs;

  @override
  void onInit() {
    super.onInit();
    switchToInstrument('Piano');
  }

  Future<void> switchToInstrument(String name) async {
    if (isSwitching.value) return;
    if (activeInstrumentName.value == name) return;

    isSwitching.value = true;
    try {
      if (_activeInstrument != null) {
        try {
          await _activeInstrument!.dispose();
        } catch (e) {
          Log.error('Error disposing instrument', e);
        }
        _activeInstrument = null;
      }

      final InstrumentHandler next = _buildHandler(name);
      await next.init();

      _activeInstrument = next;
      activeInstrumentName.value = name;
      Log.success('Switched to: $name', 'AudioManager');
    } catch (e) {
      Log.error('Failed to switch instrument', e);
    } finally {
      isSwitching.value = false;
    }
  }

  InstrumentHandler _buildHandler(String name) {
    switch (name) {
      case 'Drums':
        return AirDrumHandler();
      case 'Piano':
      default:
        return AirPianoHandler();
    }
  }

  void handleHit(HitEvent event) {
    // Only handle kit switching if we are already in Drum mode
    if (activeInstrumentName.value == 'Drums' && _activeInstrument is AirDrumHandler) {
      (_activeInstrument as AirDrumHandler).setKitByIndex(event.kit);
    }

    _activeInstrument?.processHit(event);
  }

  InstrumentHandler? get currentInstrument => _activeInstrument;

  @override
  void onClose() {
    _activeInstrument?.dispose();
    super.onClose();
  }
}
