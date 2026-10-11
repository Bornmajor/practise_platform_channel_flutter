// Pigeon contract for the battery channels.
//
// This file is NOT part of the app. It is the input for the code generator:
//   dart run pigeon --input pigeons/battery_api.dart
//   dart format lib/pigeon   (generated Dart is not formatted; CI checks it)
//
// It replaces the hand-written channel names, method names and Map keys
// that had to match between Dart and Kotlin.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    // Generated Dart code (used by BatteryScreen)
    dartOut: 'lib/pigeon/battery_api.g.dart',
    dartOptions: DartOptions(),
    // Generated Kotlin code (implemented in MainActivity / BatteryStreamHandler)
    kotlinOut: 'android/app/src/main/kotlin/com/example/practise_platform_channel_flutter/BatteryApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.practise_platform_channel_flutter',
    ),
    dartPackageName: 'practise_platform_channel_flutter',
  ),
)
// Data sent from Kotlin to Dart.
// Replaces mapOf("level" to ..., "isCharging" to ...) and BatteryInfo.fromMap.
class BatteryInfo {
  BatteryInfo({required this.level, this.isCharging});

  int level;

  // null = unknown (the one-time getBatteryLevel only returns the level)
  bool? isCharging;
}

// Dart calls Kotlin once and gets one answer.
// Replaces MethodChannel('.../battery') + invokeMethod('getBatteryLevel').
@HostApi()
abstract class BatteryHostApi {
  int getBatteryLevel();
}

// Kotlin pushes many values to Dart.
// Replaces EventChannel('.../battery_stream') + StreamHandler.
@EventChannelApi()
abstract class BatteryEventApi {
  BatteryInfo batteryUpdates();
}
