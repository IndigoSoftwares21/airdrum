class HitEvent {
  final String deviceId; // e.g: [LEFT] or [RIGHT]
  final double peak; // 0 - 127
  final double angle; // yaw angle, typically -180 to +180

  HitEvent({required this.deviceId, required this.peak, required this.angle});

  /// Factory constructor to parse the udp string
  /// Example: "[LEFT] HIT peak=75 angle=-45"
  factory HitEvent.fromString(String raw) {
    String deviceId = "UNKNOWN";
    if (raw.startsWith('[LEFT]')) deviceId = '[LEFT]';
    if (raw.startsWith('[RIGHT]')) deviceId = '[RIGHT]';

    double hitPeak = 0;
    double hitAngle = 0;

    // A brute-force quick parse for our specific contract
    final peakMatch = RegExp(r'peak=([-0-9.]+)').firstMatch(raw);
    if (peakMatch != null) {
      hitPeak = double.tryParse(peakMatch.group(1) ?? '0') ?? 0;
    }

    final angleMatch = RegExp(r'angle=([-0-9.]+)').firstMatch(raw);
    if (angleMatch != null) {
      hitAngle = double.tryParse(angleMatch.group(1) ?? '0') ?? 0;
    }

    return HitEvent(deviceId: deviceId, peak: hitPeak, angle: hitAngle);
  }

  @override
  String toString() {
    return 'HitEvent(device: $deviceId, peak: $peak, angle: $angle)';
  }
}
