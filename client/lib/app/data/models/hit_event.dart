class HitEvent {
  final String deviceId; // e.g: [LEFT] or [RIGHT]
  final double peak; // 0 - 127
  final double angle; // yaw angle, typically -180 to +180
  final int kit; // 0 - 9
  final int mode; // 0: DRUM, 1: PIANO

  HitEvent({
    required this.deviceId,
    required this.peak,
    required this.angle,
    required this.kit,
    required this.mode,
  });

  /// Factory constructor to parse the udp string
  /// Example: "[LEFT] HIT kit=0 mode=0 peak=75 angle=-45"
  factory HitEvent.fromString(String raw) {
    String deviceId = "UNKNOWN";
    if (raw.startsWith('[LEFT]')) deviceId = '[LEFT]';
    if (raw.startsWith('[RIGHT]')) deviceId = '[RIGHT]';

    double hitPeak = 0;
    double hitAngle = 0;
    int kitIndex = 0;
    int modeIndex = 0;

    // Brute-force quick parse
    final peakMatch = RegExp(r'peak=([-0-9.]+)').firstMatch(raw);
    if (peakMatch != null) {
      hitPeak = double.tryParse(peakMatch.group(1) ?? '0') ?? 0;
    }

    final angleMatch = RegExp(r'angle=([-0-9.]+)').firstMatch(raw);
    if (angleMatch != null) {
      hitAngle = double.tryParse(angleMatch.group(1) ?? '0') ?? 0;
    }

    final kitMatch = RegExp(r'kit=(\d+)').firstMatch(raw);
    if (kitMatch != null) {
      kitIndex = int.tryParse(kitMatch.group(1) ?? '0') ?? 0;
    }

    final modeMatch = RegExp(r'mode=(\d+)').firstMatch(raw);
    if (modeMatch != null) {
      modeIndex = int.tryParse(modeMatch.group(1) ?? '0') ?? 0;
    }

    return HitEvent(
      deviceId: deviceId,
      peak: hitPeak,
      angle: hitAngle,
      kit: kitIndex,
      mode: modeIndex,
    );
  }

  @override
  String toString() {
    return 'HitEvent(device: $deviceId, peak: $peak, angle: $angle)';
  }
}
