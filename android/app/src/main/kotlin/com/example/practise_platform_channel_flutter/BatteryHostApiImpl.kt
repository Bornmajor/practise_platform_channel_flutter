package com.example.practise_platform_channel_flutter

import android.content.Context
import android.os.BatteryManager

// Implements the Pigeon-generated BatteryHostApi interface.
// Replaces the MethodChannel handler (if call.method == "getBatteryLevel" ...).
class BatteryHostApiImpl(private val context: Context) : BatteryHostApi {

    // Called when Dart calls BatteryHostApi().getBatteryLevel()
    override fun getBatteryLevel(): Long {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)

        if (level < 0) {
            // Arrives in Dart as PlatformException (replaces result.error)
            throw FlutterError("UNAVAILABLE", "Battery level not available.", null)
        }

        // Dart int is 64-bit, so Pigeon uses Long
        return level.toLong()
    }
}
