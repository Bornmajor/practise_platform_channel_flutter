# Native code practice roadmap

- [x] MethodChannel – one-time battery level (`main`)
- [ ] EventChannel – live battery level + charging stream (`feature/battery-event-channel`)
  - [x] Step 1: `BatteryStreamHandler.kt` (BroadcastReceiver → EventSink)
  - [x] Step 2: register EventChannel in `MainActivity.kt`
  - [x] Step 3: `BatteryInfo` model + `BatteryState`
  - [x] Step 4: listen to the stream in `battery_screen.dart`
  - [ ] Step 5: test with emulator / `adb shell dumpsys battery`
- [x] Dart tests + CI on PRs to main (`feature/dart-tests-ci`)
- [ ] Native tests – Kotlin unit tests (JUnit + Robolectric) for BatteryStreamHandler
- [ ] Pigeon – redo the battery channels with type-safe generated code
- [ ] Text-to-Speech – mini SDK wrapper (async init, callbacks to Dart, shutdown)
- [ ] ZXing scanner – launch native Activity and return result
- [ ] MapTiler – Platform View + controller channel + delegate callbacks
