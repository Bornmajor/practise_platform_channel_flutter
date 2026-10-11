package com.example.practise_platform_channel_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.EventChannel

class BatteryStreamHandler(private val context: Context) : EventChannel.StreamHandler {

    // Holds the receiver while Dart is listening, null otherwise
    private var receiver: BroadcastReceiver? = null

    // Called when Dart starts listening to the stream
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                // Read raw values from the system broadcast
                val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)

                if (level == -1 || scale <= 0) {
                    // Send error to Dart stream (arrives in onError)
                    events.error("UNAVAILABLE", "Battery info not available.", null)
                    return
                }

                val percent = level * 100 / scale
                val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL

                // Send a Map to Dart (only simple types can cross the channel)
                events.success(
                    mapOf(
                        "level" to percent,
                        "isCharging" to isCharging
                    )
                )
            }
        }

        // Start listening for battery changes
        context.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    // Called when Dart cancels the subscription
    override fun onCancel(arguments: Any?) {
        // Stop listening to avoid leaks and duplicate events
        receiver?.let { context.unregisterReceiver(it) }
        receiver = null
    }
}