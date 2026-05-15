import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/udp_service.dart';
import '../../../data/managers/audio_manager.dart';
import '../../../data/models/hit_event.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  final UdpService _udpService = Get.find<UdpService>();
  final AudioManager _audioManager = Get.find<AudioManager>();

  final RxList<String> logs = <String>[].obs;

  // Navigation rail index tracking
  final RxInt selectedIndex = 0.obs;

  // Visual feedback tracking
  final Rx<HitEvent?> lastHitEvent = Rx<HitEvent?>(null);

  final RxBool leftConnected = false.obs;
  final RxBool rightConnected = false.obs;

  DateTime? _leftLastSeen;
  DateTime? _rightLastSeen;

  Timer? _heartbeatTimer;
  StreamSubscription<String>? _logSubscription;

  @override
  void onInit() {
    super.onInit();
    _startMessageListener();
    _startHeartbeatMonitor();
  }

  void _startMessageListener() {
    _logSubscription = _udpService.messageStream.listen((message) {
      _handleIncomingMessage(message.trim());
    });
  }

  void _handleIncomingMessage(String message) {
    // Determine the source of the message
    if (message.startsWith('[LEFT]')) {
      _leftLastSeen = DateTime.now();
      if (!leftConnected.value) {
        leftConnected.value = true;
        Log.success('LEFT stick connected', 'HomeController');
      }
    } else if (message.startsWith('[RIGHT]')) {
      _rightLastSeen = DateTime.now();
      if (!rightConnected.value) {
        rightConnected.value = true;
        Log.success('RIGHT stick connected', 'HomeController');
      }
    }

    if (message.contains('HIT')) {
      try {
        final hitEvent = HitEvent.fromString(message);
        lastHitEvent.value = hitEvent; // Trigger frontend visualizer
        _audioManager.handleHit(hitEvent);
      } catch (e) {
        Log.error('Failed to parse hit event', e);
      }
    }

    // --- Hardware Button Sync ---
    if (message.contains('MODE_CHANGE=')) {
      final modeStr = message.split('MODE_CHANGE=').last;
      final modeIndex = int.tryParse(modeStr) ?? 0;
      final targetInstrument = (modeIndex == 0) ? 'Drums' : 'Piano';
      _audioManager.switchToInstrument(targetInstrument);
      Log.info('Hardware sync: Switched to $targetInstrument', 'HomeController');
    }

    if (message.contains('KIT_CHANGE=')) {
      final kitStr = message.split('KIT_CHANGE=').last;
      final kitIndex = int.tryParse(kitStr) ?? 0;
      // We only switch kit if we are already in Drum mode
      if (_audioManager.activeInstrumentName.value == 'Drums') {
        _audioManager.handleHit(HitEvent(
          deviceId: message.contains('[LEFT]') ? '[LEFT]' : '[RIGHT]',
          peak: 0, // Mock hit to trigger kit update
          angle: 0,
          kit: kitIndex,
          mode: 0,
        ));
      }
    }

    // Add message to logs list only if it's NOT a heartbeat message
    if (!message.contains('HEARTBEAT')) {
      _addLog(message);
    }
  }

  void _addLog(String message) {
    logs.add(message);
    // Limit to last 200 entries
    if (logs.length > 200) {
      logs.removeRange(0, logs.length - 200);
    }
  }

  void _startHeartbeatMonitor() {
    // Check every second if any stick hasn't been seen for 3 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      if (leftConnected.value && _leftLastSeen != null) {
        if (now.difference(_leftLastSeen!).inSeconds >= 3) {
          leftConnected.value = false;
          Log.warning('LEFT stick disconnected (timeout)', 'HomeController');
        }
      }

      if (rightConnected.value && _rightLastSeen != null) {
        if (now.difference(_rightLastSeen!).inSeconds >= 3) {
          rightConnected.value = false;
          Log.warning('RIGHT stick disconnected (timeout)', 'HomeController');
        }
      }
    });
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    _logSubscription?.cancel();
    super.onClose();
  }
}
