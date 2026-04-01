import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

import '../../interfaces/instrument_handler.dart';
import '../../models/hit_event.dart';
import '../../../modules/settings/controllers/settings_controller.dart';

class AirPianoHandler implements InstrumentHandler {
  @override
  String get instrumentName => 'Piano (By Octave)';

  // Because piano requires playing multiple notes rapidly and simultaneously,
  // we need a pool of AudioPlayers instead of just one.
  final List<AudioPlayer> _players = [];
  int _currentPlayerIndex = 0;

  // Support separate octaves for each stick
  final RxInt _leftOctave = 3.obs;
  final RxInt _rightOctave = 4.obs;

  // For the legacy general 'currentOctave' property, we can just return the right hand,
  // or we can expose both independently.
  RxInt get leftOctave => _leftOctave;
  RxInt get rightOctave => _rightOctave;

  final RxString selectedLeftNote = 'C'.obs;
  final RxString selectedRightNote = 'G'.obs;

  @override
  Future<void> init() async {
    // Initialize a pool of 8 players for polyphony
    for (int i = 0; i < 8; i++) {
      _players.add(AudioPlayer());
    }
  }

  void setLeftOctave(int octave) {
    if (octave >= 1 && octave <= 5) _leftOctave.value = octave;
  }

  void setRightOctave(int octave) {
    if (octave >= 1 && octave <= 5) _rightOctave.value = octave;
  }

  @override
  void processHit(HitEvent event) {
    // Skip accidental noise
    double minPeak = 5.0;
    try {
      minPeak = Get.find<SettingsController>().minIntensity.value;
    } catch (_) {}
    if (event.peak < minPeak) return;

    // Use selected note instead of mapping peak
    final String note = event.deviceId == '[LEFT]' 
        ? selectedLeftNote.value 
        : selectedRightNote.value;
    final int octave = event.deviceId == '[LEFT]' 
        ? _leftOctave.value 
        : _rightOctave.value;
    
    final String noteFile = 'piano-keys/Octave-$octave/$octave$note.ogg';

    // Intensity only affects volume
    double volume = ((event.peak / 127.0) * 0.5 + 0.5).clamp(0.5, 1.0);

    _play(noteFile, volume);
  }

  void _play(String assetFile, double volume) {
    final player = _players[_currentPlayerIndex];
    player.stop();
    player.setVolume(volume);
    player.play(AssetSource(assetFile));
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
  }

  @override
  Future<void> dispose() async {
    for (var player in _players) {
      await player.dispose();
    }
    _players.clear();
  }
}
