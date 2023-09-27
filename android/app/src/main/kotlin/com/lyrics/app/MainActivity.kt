package com.lyrics.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: MethodChannel.MethodCallHandler, EventChannel.StreamHandler, FlutterActivity() {
    companion object {
        private const val methodChannelName = "com.lyrics.app:method_channel"
        private const val mediaSessionsEventChannelName = "com.lyrics.app:event_channel-media_sessions"
        private var methodChannel: MethodChannel? = null
        private var mediaSessionsEventChannel: EventChannel? = null
    }

    //From FlutterActivity
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.i("MainActivity", "configureFlutterEngine() Called")
        super.configureFlutterEngine(flutterEngine)

        Helpers.cacheFlutterEngine(flutterEngine)

        initialize(flutterEngine.dartExecutor.binaryMessenger)
        startAllServicesAndListeners()
    }

    private fun initialize(binaryMessenger: BinaryMessenger) {
        methodChannel = MethodChannel(binaryMessenger, methodChannelName)
        methodChannel!!.setMethodCallHandler(this)
        mediaSessionsEventChannel = EventChannel(binaryMessenger, mediaSessionsEventChannelName)
        mediaSessionsEventChannel!!.setStreamHandler(this)
    }

    private fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        mediaSessionsEventChannel?.setStreamHandler(null)
        mediaSessionsEventChannel = null
    }

    private fun startAllServicesAndListeners() {
        if (!MediaNotificationListener.isNotificationAccessPermissionGiven(this)) {
            //throw Exception("Notification access permission is not given!")
            return
        }
        MediaSessionListener.initialize(this)
        MediaNotificationListener.startListening(this)
    }

    private fun stopServicesAndListeners() {
        if (MediaNotificationListener.isNotificationListenerServiceRunning()) {
            MediaNotificationListener.stopListening(this)
        }
        MediaSessionListener.dispose()
    }

    // From MethodChannel
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i("AndroidSide", "MethodCallHandlerImp: onMethodCall() Called, method ${call.method}, arguments: ${call.arguments}")
        when (call.method) {
            "startAllServicesAndListeners" -> {
                try {
                    startAllServicesAndListeners()
                    result.success(null)
                } catch (e: Exception) {
                    result.error(e.toString(), e.toString(), e)
                }
            }

            "stopAllServicesAndListeners" -> {
                stopServicesAndListeners()
                result.success(null)
            }

            "notification.start_notification_service" -> {
                MediaNotificationListener.startListening(this)
                result.success(null)
            }

            "notification.stop_notification_service" -> {
                MediaNotificationListener.stopListening(this)
                result.success(null)
            }

            "notification.is_service_running" -> {
                result.success(MediaNotificationListener.isNotificationListenerServiceRunning())
            }

            /*"notification.is_service_running_method" -> {
                val isRunning = MediaNotificationListener.isServiceRunning(this)
                result.success(isRunning)
            }*/

            "notification.is_notification_access_permission_given" -> {
                val isPermissionGiven = MediaNotificationListener.isNotificationAccessPermissionGiven(this)
                result.success(isPermissionGiven)
            }

            "notification.open_notification_access_permission_settings" -> {
                MediaNotificationListener.openNotificationAccessPermissionSettings(this)
                result.success(null)
            }

            "notification.get_ongoing_notifications" -> {
                val notifications = MediaNotificationListener.getOngoingNotifications()
                //result.success(notifications)
                result.success(null)
            }

            "wakelock.acquire_wakelock" -> {
                MediaNotificationListener.acquireWakeLock(this)
                result.success(null)
            }

            "wakelock.release_wakelock" -> {
                MediaNotificationListener.releaseWakeLock()
                result.success(null)
            }

            "wakelock.is_acquired_wakelock" -> {
                val doesHaveWakeLock = MediaNotificationListener.hasWakeLock()
                result.success(doesHaveWakeLock)
            }

            "media_session.initialize" -> {
                Helpers.setDartInitializerCallback(context, (call.arguments as Number?)?.toLong())
                MediaSessionListener.initialize(this)
                result.success(null)
            }

            "media_session.get_sessions" -> {
                val sessions = MediaSessionListener.getMediaInfoListOfActiveSessions(this)
                result.success(sessions.map { e -> e.toJson() })
            }

            "media_session.refresh" -> {
                MediaSessionListener.refresh(this)
                result.success(null)
            }

            "media_session.controls.play" -> {
                val argument = call.arguments as String
                MediaSessionListener.play(argument)
            }

            "media_session.controls.pause" -> {
                val argument = call.arguments as String
                MediaSessionListener.pause(argument)
            }

            "media_session.controls.skipToNext" -> {
                val argument = call.arguments as String
                MediaSessionListener.skipToNext(argument)
            }

            "media_session.controls.skipToPrevious" -> {
                val argument = call.arguments as String
                MediaSessionListener.skipToPrevious(argument)
            }

            "media_session.controls.fastForward" -> {
                val argument = call.arguments as String
                MediaSessionListener.fastForward(argument)
            }

            "media_session.controls.rewind" -> {
                val argument = call.arguments as String
                MediaSessionListener.rewind(argument)
            }

            "media_session.controls.prepare" -> {
                val argument = call.arguments as String
                MediaSessionListener.prepare(argument)
            }

            "media_session.controls.stop" -> {
                val argument = call.arguments as String
                MediaSessionListener.stop(argument)
            }

            "media_session.controls.seekTo" -> {
                val argument = call.arguments as Map<*, *>
                MediaSessionListener.seekTo(argument["packageName"] as String, (argument["duration"] as Number).toLong())
            }

            "media_session.controls.setPlaybackSpeed" -> {
                val argument = call.arguments as Map<*, *>
                MediaSessionListener.setPlaybackSpeed(argument["packageName"] as String, (argument["speed"] as Number).toFloat())
            }

            "media_session.controls.playFromMediaID" -> {
                val argument = call.arguments as Map<*, *>
                MediaSessionListener.playFromMediaID(argument["packageName"] as String, argument["mediaID"] as String)
            }
        }
    }

    // From EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.i("MediaSessionsStreamHandler", "onListen() Called")
        MediaSessionListener.setEventSink(this, events)
        //eventSink?.success(ongoingNotifications)
    }

    // From EventChannel.StreamHandler
    override fun onCancel(arguments: Any?) {
        Log.i("MediaSessionsStreamHandler", "onCancel() Called")
        MediaSessionListener.setEventSink(this, null)
    }
}
