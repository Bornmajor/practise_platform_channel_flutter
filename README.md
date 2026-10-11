# practise_platform_channel_flutter

A practice project for learning how Flutter talks to **native platform code** (Kotlin on Android) using **platform channels**.

## Why platform channels?

Flutter code runs in the **Dart runtime** (inside the Flutter engine), while Android code runs in **ART** (Android Runtime). The two runtimes have separate memory and type systems, so Dart cannot call Kotlin functions directly. Instead, they exchange simple messages (`int`, `String`, `bool`, `List`, `Map`, ...) through a **platform channel**.

```
Dart (Flutter engine)                         Kotlin (ART)
─────────────────────                         ────────────
invokeMethod('getBatteryLevel')  ──────────►  setMethodCallHandler
                                              BatteryManager → 80
Future<int> completes with 80    ◄──────────  result.success(80)
```

## What this branch achieves: battery level via `MethodChannel`

The app shows the device battery level, read natively from Android and sent to Flutter on request.

- **Channel name:** `com.example.practise_platform_channel_flutter/battery`
- **Method:** `getBatteryLevel` → returns the battery percentage as `int`

### Android side – `android/app/src/main/kotlin/.../MainActivity.kt`
- Registers a `MethodChannel` in `configureFlutterEngine`.
- Handles `getBatteryLevel` using `BatteryManager.BATTERY_PROPERTY_CAPACITY`.
- Returns `result.success(level)`, `result.error("UNAVAILABLE", ...)` if the value can't be read, or `result.notImplemented()` for unknown methods.

### Flutter side – `lib/`
- `battery_screen.dart` – calls `invokeMethod('getBatteryLevel')` when the screen opens and catches `PlatformException`.
- `battery_state.dart` – a sealed class (`BatteryLoading`, `BatterySuccess`, `BatteryError`) so the UI uses an exhaustive `switch` to show a loader, the level, or an error.

### Key takeaways
- A `MethodChannel` is **request → single response**, and always **asynchronous** (`Future`).
- Channel and method names are plain strings and must match exactly on both sides; typos only fail at runtime.
- Native errors reach Dart as `PlatformException`.

## Running

Android only for now (iOS needs a Mac).

```bash
flutter pub get
flutter run
```

To test different values on an emulator:

```bash
adb shell dumpsys battery set level 42
adb shell dumpsys battery reset
```

## Roadmap

- [x] MethodChannel – one-time battery level (this branch)
- [ ] EventChannel – live battery level and charging stream
- [ ] Pigeon – type-safe generated channels
- [ ] Text-to-Speech – mini native SDK wrapper
- [ ] ZXing – launch a native scanner Activity and return the result
- [ ] MapTiler – embed a native map with Platform Views
