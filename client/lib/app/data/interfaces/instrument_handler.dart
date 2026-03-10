import '../models/hit_event.dart';

/// Interface that any virtual instrument must implement.
/// This enforces strict separation of concerns from the UDP layer.
abstract class InstrumentHandler {
  /// Unique name for UI dropdowns
  String get instrumentName;

  /// Called once when the instrument is selected or the app boots
  Future<void> init();

  /// Pass the parsed physical hit to the instrument logic
  void processHit(HitEvent event);

  /// Called when switching away from this instrument
  Future<void> dispose();
}
