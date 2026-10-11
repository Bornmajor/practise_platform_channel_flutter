package com.example.practise_platform_channel_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity(){

  override fun configureFlutterEngine(flutterEngine: FlutterEngine){
    super.configureFlutterEngine(flutterEngine)

    val messenger = flutterEngine.dartExecutor.binaryMessenger

    // One-time battery level (replaces MethodChannel + setMethodCallHandler)
    BatteryHostApi.setUp(messenger, BatteryHostApiImpl(applicationContext))

    // Live battery updates (replaces EventChannel + setStreamHandler)
    BatteryUpdatesStreamHandler.register(messenger, BatteryStreamHandler(applicationContext))
  }
}
