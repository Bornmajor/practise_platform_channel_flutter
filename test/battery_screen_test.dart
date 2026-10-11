import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practise_platform_channel_flutter/battery_screen.dart';

// Same names as in MainActivity.kt and BatteryScreen
const methodChannel = MethodChannel(
  'com.example.practise_platform_channel_flutter/battery',
);
const eventChannel = EventChannel(
  'com.example.practise_platform_channel_flutter/battery_stream',
);

// No Kotlin runs in widget tests, so we pretend to be the native side
TestDefaultBinaryMessenger get messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

// Fake Kotlin BatteryStreamHandler: runs onListen when Dart starts listening
void mockBatteryStream(
  void Function(MockStreamHandlerEventSink events) onListen, {
  void Function()? onCancel,
}) {
  messenger.setMockStreamHandler(
    eventChannel,
    MockStreamHandler.inline(
      onListen: (arguments, events) => onListen(events),
      onCancel: (arguments) => onCancel?.call(),
    ),
  );
}

Future<void> pumpBatteryScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BatteryScreen()));
  // Let the mocked channel deliver its first event
  await tester.pump();
}

void main() {
  tearDown(() {
    messenger.setMockStreamHandler(eventChannel, null);
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  group('EventChannel (live stream)', () {
    testWidgets('shows loading until the first event arrives', (tester) async {
      mockBatteryStream((events) {}); // Never sends anything

      await pumpBatteryScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows level and charging state', (tester) async {
      mockBatteryStream(
        (events) => events.success({'level': 80, 'isCharging': true}),
      );

      await pumpBatteryScreen(tester);

      expect(find.text('Battery level: 80%'), findsOneWidget);
      expect(find.text('⚡ Charging'), findsOneWidget);
    });

    testWidgets('shows not charging', (tester) async {
      mockBatteryStream(
        (events) => events.success({'level': 15, 'isCharging': false}),
      );

      await pumpBatteryScreen(tester);

      expect(find.text('Battery level: 15%'), findsOneWidget);
      expect(find.text('🔋 Not charging'), findsOneWidget);
    });

    testWidgets('shows native error sent with events.error()', (tester) async {
      mockBatteryStream(
        (events) => events.error(
          code: 'UNAVAILABLE',
          message: 'Battery info not available.',
        ),
      );

      await pumpBatteryScreen(tester);

      expect(find.text('Battery info not available.'), findsOneWidget);
    });

    testWidgets('shows error when native sends invalid data', (tester) async {
      mockBatteryStream(
        (events) => events.success({'level': '80', 'isCharging': true}),
      );

      await pumpBatteryScreen(tester);

      expect(find.textContaining('Invalid battery data'), findsOneWidget);
    });

    testWidgets('cancels the native stream when screen is disposed', (
      tester,
    ) async {
      var cancelled = false;
      mockBatteryStream(
        (events) => events.success({'level': 80, 'isCharging': true}),
        onCancel: () => cancelled = true,
      );

      await pumpBatteryScreen(tester);
      expect(cancelled, isFalse);

      // Remove the screen from the tree, which calls dispose()
      await tester.pumpWidget(const SizedBox());

      expect(cancelled, isTrue);
    });
  });

  group('MethodChannel (refresh once)', () {
    testWidgets('shows one-time level with unknown charging state', (
      tester,
    ) async {
      mockBatteryStream(
        (events) => events.success({'level': 80, 'isCharging': true}),
      );
      final calls = <String>[];
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        calls.add(call.method);
        return 42;
      });

      await pumpBatteryScreen(tester);
      await tester.tap(find.text('Refresh once (MethodChannel)'));
      await tester.pump();

      expect(calls, ['getBatteryLevel']);
      expect(find.text('Battery level: 42%'), findsOneWidget);
      expect(
        find.text('Charging status unknown (one-time read)'),
        findsOneWidget,
      );
    });

    testWidgets('shows native error sent with result.error()', (tester) async {
      mockBatteryStream(
        (events) => events.success({'level': 80, 'isCharging': true}),
      );
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        throw PlatformException(
          code: 'UNAVAILABLE',
          message: 'Battery level not available.',
        );
      });

      await pumpBatteryScreen(tester);
      await tester.tap(find.text('Refresh once (MethodChannel)'));
      await tester.pump();

      expect(find.text('Battery level not available.'), findsOneWidget);
    });
  });
}
