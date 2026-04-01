import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

import '../../interfaces/instrument_handler.dart';
import '../../models/hit_event.dart';
import '../../../modules/settings/controllers/settings_controller.dart';

class AirDrumHandler implements InstrumentHandler {
  final RxString selectedKit = 'set-1'.obs;
  static const List<String> availableKits = ['set-1'];

  /// How far you need to sweep outward (degrees) to hit the "edge" voice.
  /// Below this → centered voice (snare / tom).
  /// Selected voices per stick
  final RxString selectedRightVoice = 'snare'.obs;
  final RxString selectedLeftVoice = 'bass'.obs;

  static const int _poolSize = 3;
  static const _voices = ['bass', 'snare', 'tom', 'crash'];

  final Map<String, List<AudioPlayer>> _pools = {};
  final Map<String, int> _indices = {};

  @override
  String get instrumentName => 'Drums';

  @override
  Future<void> init() async {
    for (final voice in _voices) {
      _pools[voice] = List.generate(_poolSize, (_) => AudioPlayer());
      _indices[voice] = 0;
    }
  }

  @override
  Future<void> dispose() async {
    await Future.wait(
      _pools.values.expand((pool) => pool).map((p) => p.dispose()),
    );
    _pools.clear();
    _indices.clear();
  }

  @override
  void processHit(HitEvent event) {
    double minPeak = 5.0;
    try {
      minPeak = Get.find<SettingsController>().minIntensity.value;
    } catch (_) {}
    if (event.peak < minPeak) return;

    final double volume = ((event.peak / 127.0) * 0.65 + 0.35).clamp(0.35, 1.0);
    _play(_mapToVoice(event.deviceId), volume);
  }

  /// Always use manually selected voice
  String _mapToVoice(String deviceId) {
    return deviceId == '[RIGHT]'
        ? selectedRightVoice.value
        : selectedLeftVoice.value;
  }

  void _play(String voice, double volume) {
    final pool = _pools[voice];
    if (pool == null) return;
    final idx = _indices[voice]!;
    final player = pool[idx];
    player.setVolume(volume);
    player.play(AssetSource('drums/${selectedKit.value}/$voice.wav.mp3'));
    _indices[voice] = (idx + 1) % _poolSize;
  }

  void setKit(String kitName) {
    if (availableKits.contains(kitName)) selectedKit.value = kitName;
  }
}
