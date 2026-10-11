package com.example.practise_platform_channel_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

import android.content.Context
import android.os.BatteryManager

class MainActivity : FlutterActivity(){
  // Channel identifier
  private val CHANNEL = "com.example.practise_platform_channel_flutter/battery"
  // Event channel identifier for live battery updates
  private val EVENT_CHANNEL = "com.example.practise_platform_channel_flutter/battery_stream"

  // 
  override fun configureFlutterEngine(flutterEngine: FlutterEngine){
    super.configureFlutterEngine(flutterEngine)

    //Register a MethodChannel listener
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call, result ->

        //Handle method calls from Flutter
        if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    // Send success result back to Dart
                    result.success(batteryLevel)
                } else {
                    // Send error back to Dart if hardware query fails
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                // If Dart called a method name that doesn't exist in Kotlin
                result.notImplemented()
            }

    }

    //Register an EventChannel for streaming battery updates
    EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        .setStreamHandler(BatteryStreamHandler(applicationContext))

  }

  private fun getBatteryLevel():Int{
    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  }
}
