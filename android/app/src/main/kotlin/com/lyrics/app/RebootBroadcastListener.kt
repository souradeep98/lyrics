package com.lyrics.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.Log

class RebootBroadcastListener : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_REBOOT, Intent.ACTION_BOOT_COMPLETED -> {
                Log.i("RebootBroadcastListener", "Initializing MediaSessionListener after reboot")

                if (MediaNotificationListener.isNotificationAccessPermissionGiven(context)) {
                    Helpers.callDartInitializerCallback(context)
                    MediaSessionListener.initialize(context)
                    MediaNotificationListener.startListening(context)
                }
            }
            else -> {
                Log.i("RebootBroadcastListener", intent.action.toString())
            }
        }
    }
}