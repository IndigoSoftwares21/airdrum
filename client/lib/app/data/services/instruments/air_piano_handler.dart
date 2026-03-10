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
    // 1. Convert physical hit intensity (Peak: 0-127) to a Piano Note
    // Weak hits = C, Hard hits = B
    String noteFile = _mapPeakToNote(event.peak, event.deviceId);

    // 2. Volume control
    // Since we are using peak for Pitch, we give it a generous minimum volume
    // so the low notes (weak hits) are still clearly audible.
    double volume = ((event.peak / 127.0) * 0.5 + 0.5).clamp(0.5, 1.0);

    // Skip extreme accidental static noise
    double minPeak = 5.0;
    try {
      minPeak = Get.find<SettingsController>().minIntensity.value;
    } catch (_) {}

    if (event.peak < minPeak) return;

    _play(noteFile, volume);
  }

  void _play(String assetFile, double volume) {
    final player = _players[_currentPlayerIndex];

    // Stop the specific player slot if it was still decaying
    player.stop();
    player.setVolume(volume);

    // Play the new note
    player.play(AssetSource(assetFile));

    // Rotate the pool index for the next incoming hit
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
  }

  String _mapPeakToNote(double peak, String deviceId) {
    // The peak is roughly between 0 and 127.
    // A natural scale has 7 white keys. Let's slice the 127 intensity into 7 buckets.
    // That's roughly 18 intensity points per note.

    // Use logarithmic or direct bucket slicing:
    int sliceIndex = (peak / (128.0 / 7.0)).floor();

    // Boundary safety
    sliceIndex = sliceIndex.clamp(0, 6);

    const List<String> notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    String note = notes[sliceIndex];

    // E.g., assets/piano-keys/Octave-4/4C.ogg
    int octave = deviceId == '[LEFT]' ? _leftOctave.value : _rightOctave.value;
    return 'piano-keys/Octave-$octave/$octave$note.ogg';
  }

  @override
  Future<void> dispose() async {
    for (var player in _players) {
      await player.dispose();
    }
    _players.clear();
  }
}
