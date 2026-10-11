// Typed Dart version of the battery data sent from Kotlin.
class BatteryInfo {
  final int level;

  // null = unknown (the one-time MethodChannel only returns the level)
  final bool? isCharging;

  const BatteryInfo({required this.level, this.isCharging});

  // Build from the raw Map sent through the EventChannel:
  // {"level": 80, "isCharging": true}
  factory BatteryInfo.fromMap(Map<Object?, Object?> map) {
    final level = map['level'];
    final isCharging = map['isCharging'];

    // Check types, because the channel gives no compile-time guarantees
    if (level is! int || isCharging is! bool) {
      throw FormatException('Invalid battery data: $map');
    }

    return BatteryInfo(level: level, isCharging: isCharging);
  }
}
