import 'package:flutter_test/flutter_test.dart';
import 'package:practise_platform_channel_flutter/battery_info.dart';

void main() {
  group('BatteryInfo.fromMap', () {
    test('parses a valid map from the EventChannel', () {
      final info = BatteryInfo.fromMap({'level': 80, 'isCharging': true});

      expect(info.level, 80);
      expect(info.isCharging, true);
    });

    test('parses not charging', () {
      final info = BatteryInfo.fromMap({'level': 15, 'isCharging': false});

      expect(info.level, 15);
      expect(info.isCharging, false);
    });

    test('throws FormatException when level has the wrong type', () {
      expect(
        () => BatteryInfo.fromMap({'level': '80', 'isCharging': true}),
        throwsFormatException,
      );
    });

    test('throws FormatException when isCharging is missing', () {
      expect(() => BatteryInfo.fromMap({'level': 80}), throwsFormatException);
    });

    test('throws FormatException for an empty map', () {
      expect(() => BatteryInfo.fromMap({}), throwsFormatException);
    });
  });

  test('isCharging is null (unknown) when only level is known', () {
    const info = BatteryInfo(level: 42);

    expect(info.level, 42);
    expect(info.isCharging, isNull);
  });
}
