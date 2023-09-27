package com.lyrics.app

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import io.flutter.Log
import io.flutter.plugin.common.EventChannel

class MediaNotificationListener: NotificationListenerService() {
    companion object {
        @JvmStatic
        private val ongoingNotifications = mutableSetOf<StatusBarNotification>()

        @JvmStatic
        private var eventSink: EventChannel.EventSink? = null

        @JvmStatic
        private var notificationListenerServiceRunning: Boolean = false

        @JvmStatic
        private var acquiredWakeLock : PowerManager.WakeLock? = null

        @JvmStatic
        private var isForeground: Boolean? = null

        fun isNotificationAccessPermissionGiven(context: Context): Boolean {
            val packageName: String = context.packageName
            Log.i("MediaNotificationListener : isNotificationAccessPermissionGiven()", "packageName: $packageName")
            val flat: String =
                Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
            Log.i("MediaNotificationListener : isNotificationAccessPermissionGiven()", "flat: $flat")
            return flat.contains(packageName)
        }

        fun openNotificationAccessPermissionSettings(context: Context) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }

        fun isNotificationListenerServiceRunning(): Boolean {
            return notificationListenerServiceRunning
        }

        fun startListening(
            context: Context,
            foreground: Boolean = true,
            shouldAcquireWakeLock: Boolean = true,
        ) {
            if (notificationListenerServiceRunning) {
                if (isForeground == foreground) {
                    return
                }
            }

            val tag = "MediaNotificationListener : startListening()"
            Log.i(tag, "Called startListening()")
            if (shouldAcquireWakeLock) {
                acquireWakeLock(context)
                Log.i(tag, "acquired wake lock")
            }

            val intent = Intent(context, this::class.java.declaringClass)

            if (foreground) {
                Log.i(tag, "Starting foreground service")
                context.startForegroundService(intent)

                isForeground = true
                Log.i(tag, "started service in foreground mode")
            } else {
                context.startService(intent)
                isForeground = false
                Log.i(tag, "started service in background mode")
            }
            notificationListenerServiceRunning = true
        }

        fun stopListening(context: Context) {
            val tag = "MediaNotificationListener : stopListening()"
            Log.i(tag, "Called stopListening()")
            val intent = Intent(context, this::class.java.declaringClass)
            context.stopService(intent)
            releaseWakeLock()
            notificationListenerServiceRunning = false
            isForeground = null
            Log.i(tag, "stopped service")
        }

        /*fun isServiceRunning(context: Context): Boolean {
            val tag = "MediaNotificationListener : isServiceRunning()"
            Log.i(tag, "Called isServiceRunning()")
            val manager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager?

            val serviceClassName = this::class.java.declaringClass.name

            Log.i(tag, "Service class name: $serviceClassName")

            @Suppress("DEPRECATION")
            for (service in manager!!.getRunningServices(Int.MAX_VALUE)) {
                Log.i(tag, "checking service: ${service.service.className}")
                if (serviceClassName == service.service.className) {
                    return true
                }
            }
            return false
        }*/

        fun getOngoingNotifications(): List<StatusBarNotification> {
            return ongoingNotifications.toList()
        }

        @SuppressLint("WakelockTimeout")
        fun acquireWakeLock(context: Context) {
            try {
                acquiredWakeLock = (context.getSystemService(POWER_SERVICE) as PowerManager).run {
                    newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "IsolateHolderService::WAKE_LOCK").apply {
                        setReferenceCounted(false)
                    }
                }
                acquiredWakeLock!!.acquire()
            } catch (e: Throwable) {
                Log.e("MediaNotificationListener : acquireWakeLock()", "Error while acquiring wakelock: $e", e)
            }
        }

        fun releaseWakeLock() {
            acquiredWakeLock?.release()
        }

        fun hasWakeLock(): Boolean {
            return acquiredWakeLock != null
        }

        fun setEventSink(events: EventChannel.EventSink?) {
            eventSink = events
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i("MediaNotificationListener", "onStartCommand(): intent: $intent, flags: $flags, startId: $startId")
        startForegroundInternal()
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onListenerConnected() {
        Log.i("MediaNotificationListener", "onListenerConnected()")
        ongoingNotifications.clear()
        ongoingNotifications.addAll(activeNotifications)
    }

    // From NotificationListenerService
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.i("MediaNotificationListener", "onNotificationPosted: $sbn")
        val notification = sbn.notification

        ongoingNotifications.add(sbn)

        if (notification != null) {
            // Extract information from the notification
            val title = notification.extras.getCharSequence(Notification.EXTRA_TITLE)
            val text = notification.extras.getCharSequence(Notification.EXTRA_TEXT)

            ongoingNotifications.add(sbn)

            //eventSink?.success(ongoingNotifications) //TODO: implement
            Log.i("MediaNotificationListener", "Received notification - Title: $title, Text: $text")
        }
        MediaSessionListener.refresh(this)
    }

    // From NotificationListenerService
    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Handle notification removal
        Log.i("MediaNotificationListener", "onNotificationRemoved: $sbn")
        if (sbn != null) {
            ongoingNotifications.remove(sbn)
            //eventSink?.success(ongoingNotifications)
        }
        MediaSessionListener.refresh(this)
    }

    //@SuppressLint("DiscouragedApi")
    private fun startForegroundInternal() {
        val tag = "MediaNotificationListener : onCreate()"
        val channelID = "media_notification_listener"

        // create a channel for notification
        val channel = NotificationChannel(channelID, "Media Notifications Listener", NotificationManager.IMPORTANCE_HIGH)
        val imageID = resources.getIdentifier("ic_launcher", "mipmap", packageName)

        Log.i(tag, "Creating Notification Channel")

        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)

        Log.i(tag, "Notification Channel Created")

        val notification = NotificationCompat.Builder(this, channelID)
            .setContentTitle("Listening to media notifications")
            .setContentText("Listening to media notifications on your device")
            .setShowWhen(false)
            .setSubText("")
            .setSmallIcon(imageID)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
        Log.i(tag, "Starting foreground")
        startForeground(100, notification)
    }
}