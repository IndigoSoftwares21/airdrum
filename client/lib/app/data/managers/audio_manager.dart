import 'package:get/get.dart';

import '../interfaces/instrument_handler.dart';
import '../services/instruments/air_piano_handler.dart';
import '../models/hit_event.dart';
import '../../utils/logger.dart';

class AudioManager extends GetxService {
  final Map<String, InstrumentHandler> _instruments = {
    'Piano': AirPianoHandler(),
    // Future: 'Drums': AirDrumHandler(),
  };

  InstrumentHandler? _activeInstrument;
  final RxString activeInstrumentName = 'Piano'.obs;

  @override
  void onInit() {
    super.onInit();
    // Default boot to Piano
    switchToInstrument('Piano');
  }

  Future<void> switchToInstrument(String name) async {
    final instrument = _instruments[name];
    if (instrument != null) {
      if (_activeInstrument != null) {
        await _activeInstrument!.dispose();
      }
      _activeInstrument = instrument;
      await _activeInstrument!.init();
      activeInstrumentName.value = name;
      Log.success('Switched to instrument: $name', 'AudioManager');
    }
  }

  void handleHit(HitEvent event) {
    _activeInstrument?.processHit(event);
  }

  /// Expose the current instrument instance so the UI can tweak its specific settings
  /// e.g. Octave for Piano, Kit Type for Drums
  InstrumentHandler? get currentInstrument => _activeInstrument;

  @override
  void onClose() {
    _activeInstrument?.dispose();
    super.onClose();
  }
}
