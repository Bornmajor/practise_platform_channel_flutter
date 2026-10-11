# practise_platform_channel_flutter

![CI](https://github.com/Bornmajor/practise_platform_channel_flutter/actions/workflows/ci.yml/badge.svg)

A practice project for learning how Flutter talks to **native platform code** (Kotlin on Android) using **platform channels**.

## Why platform channels?

Flutter code runs in the **Dart runtime** (inside the Flutter engine), while Android code runs in **ART** (Android Runtime). The two runtimes have separate memory and type systems, so Dart cannot call Kotlin functions directly. Instead, they exchange simple messages (`int`, `String`, `bool`, `List`, `Map`, ...) through a **platform channel**.

## What the app does

A **Device Status** screen that shows the battery level and charging state:

- **Live updates** through an `EventChannel`: the screen updates by itself when the level changes or a charger is plugged in or unplugged.
- **Refresh once** button through a `MethodChannel`: a one-time read, kept to compare both patterns.

| | MethodChannel | EventChannel |
|---|---|---|
| Direction | Dart asks → native answers **once** | Native pushes **many times** |
| Dart API | `invokeMethod()` → `Future` | `receiveBroadcastStream()` → `Stream` |
| Native API | `setMethodCallHandler` + `result.success()` | `StreamHandler` + `events.success()` |
| Channel name | `.../battery` | `.../battery_stream` |

## MethodChannel – one-time battery level

```
Dart                                          Kotlin (ART)
invokeMethod('getBatteryLevel')  ──────────►  setMethodCallHandler
                                              BatteryManager → 80
Future<int> completes with 80    ◄──────────  result.success(80)
```

- **Android** – `MainActivity.kt` registers the channel in `configureFlutterEngine` and answers `getBatteryLevel` using `BatteryManager.BATTERY_PROPERTY_CAPACITY`. It returns `result.error("UNAVAILABLE", ...)` on failure and `result.notImplemented()` for unknown methods.
- **Flutter** – `battery_screen.dart` calls `invokeMethod` when **Refresh once** is pressed and catches `PlatformException`.

## EventChannel – live battery stream

```
Dart                                          Kotlin (ART)
.listen()  ────────────────────────────────►  onListen()  → registerReceiver(ACTION_BATTERY_CHANGED)
BatterySuccess(info)  ◄── Map ─────────────  events.success({level, isCharging})
          ... battery changes ...
BatterySuccess(info)  ◄── Map ─────────────  events.success(...)
cancel() in dispose  ──────────────────────►  onCancel()  → unregisterReceiver()
```

- **Android** – `BatteryStreamHandler.kt` implements `EventChannel.StreamHandler`. A `BroadcastReceiver` listens for `ACTION_BATTERY_CHANGED` (a sticky broadcast, so the current value arrives immediately) and sends `{"level": Int, "isCharging": Boolean}`. `MainActivity.kt` registers it with `applicationContext` to avoid leaking the Activity.
- **Flutter** – `battery_screen.dart` listens in `initState` and cancels in `dispose`. `battery_info.dart` converts the raw `Map<Object?, Object?>` into a typed `BatteryInfo` and throws `FormatException` for invalid data. `battery_state.dart` is a sealed class (`BatteryLoading`, `BatterySuccess`, `BatteryError`) rendered with an exhaustive `switch`.

## Key takeaways

- Only simple types cross a channel: native objects must be converted to a `Map` and rebuilt in Dart.
- Channel calls are always **asynchronous**.
- Channel and method names are plain strings that must match on both sides; typos only fail at runtime.
- Native errors reach Dart as `PlatformException` (from `result.error()` / `events.error()`).
- Pair `listen()` in `initState` with `cancel()` in `dispose()`, and native `onListen` with `onCancel`, to avoid leaks.
- Pass `applicationContext` (not the Activity) to long-lived native objects.
- After an `await`, check `mounted` before calling `setState`.

## Tests

Dart tests run without Android by **mocking the native side** of the channels:

- `test/battery_info_test.dart` – unit tests for `BatteryInfo.fromMap`.
- `test/battery_screen_test.dart` – widget tests using `setMockStreamHandler` / `setMockMethodCallHandler` to fake Kotlin: loading, success, charging state, native errors, invalid data, and `onCancel` on dispose.

```bash
flutter test
```

**CI** (`.github/workflows/ci.yml`) runs on every pull request to `main` and on pushes to `main`: format check, `flutter analyze`, and `flutter test`.

## Running

Android only for now (iOS needs a Mac).

```bash
flutter pub get
flutter run
```

Simulate battery changes on an emulator while the app runs:

```bash
adb shell dumpsys battery set level 42
adb shell dumpsys battery unplug
adb shell dumpsys battery reset
```

## Roadmap

See [PRACTICE_TODO.md](PRACTICE_TODO.md). Next up: **Pigeon** – replace the hand-written channels with type-safe generated code.
