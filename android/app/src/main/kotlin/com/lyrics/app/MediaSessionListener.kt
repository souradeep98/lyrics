package com.lyrics.app

import android.content.ComponentName
import android.content.Context
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.view.FlutterCallbackInformation

class MediaSessionListener {
    private class OnActiveSessionChangedListenerClass(val context: Context) : MediaSessionManager.OnActiveSessionsChangedListener {
        override fun onActiveSessionsChanged(mediaControllers: MutableList<MediaController>?) {
            updateSessions(context, mediaControllers)
        }
    }

    /*private class OnMediaKeyEventSessionChangedListenerClass : MediaSessionManager.OnMediaKeyEventSessionChangedListener {
        override fun onMediaKeyEventSessionChanged(packageName: String, sessionToken: MediaSession.Token?) {

        }
    }*/

    companion object {
        @JvmStatic
        private var eventSink: EventChannel.EventSink? = null

        @JvmStatic
        private var mediaSessionManager: MediaSessionManager? = null

        @JvmStatic
        private val ongoingMediaSessions = mutableMapOf<String, MediaController>()

        private const val tag = "MediaSessionListener"

        @JvmStatic
        private lateinit var onActiveSessionChangedListener: MediaSessionManager.OnActiveSessionsChangedListener

        @JvmStatic
        private lateinit var mediaNotificationListenerCN: ComponentName

        fun initialize(context: Context) {
            if (!MediaNotificationListener.isNotificationAccessPermissionGiven(context)) {
                //MediaNotificationListener.openNotificationAccessPermissionSettings(context)
                return
            }

            onActiveSessionChangedListener = OnActiveSessionChangedListenerClass(context)

            Log.i(tag, "Getting MediaSessionManager")

            mediaSessionManager = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager

            Log.i(tag, "Got MediaSessionManager")

            mediaNotificationListenerCN = ComponentName(context,
                MediaNotificationListener::class.java.name
            )

            updateSessions(context)

            Log.i(tag, "Adding OnActiveSessionsChangedListener")

            mediaSessionManager!!.addOnActiveSessionsChangedListener(onActiveSessionChangedListener, mediaNotificationListenerCN)
        }

        fun dispose() {
            mediaSessionManager?.removeOnActiveSessionsChangedListener(onActiveSessionChangedListener)
        }

        private fun updateSessions(context: Context, mediaControllers: MutableList<MediaController>? = null, notifyEventSink: Boolean = true) {
            Log.i(tag, "Called updateSessions with: ${mediaControllers?.size}")

            val newMediaControllers = mediaControllers ?: mediaSessionManager!!.getActiveSessions(mediaNotificationListenerCN)

            ongoingMediaSessions.clear()

            for (x in newMediaControllers) {
                //mediaSessionManager.addOnMediaKeyEventSessionChangedListener({}, OnMediaKeyEventSessionChangedListenerClass())
                ongoingMediaSessions[x.packageName] = x
            }

            Log.i(tag, "Set new controllers")

            val sessionsInfo = getMediaInfoListOfActiveSessions(context)

            Log.i(tag, sessionsInfo.toString())

            if (notifyEventSink) {
                eventSink?.success(sessionsInfo.map { e -> e.toJson() })
            }
        }

        fun getMediaInfoListOfActiveSessions(context: Context, refresh: Boolean = false): List<MediaInfo> {
            if (refresh) {
                updateSessions(context, notifyEventSink = false)
            }
            return ongoingMediaSessions.values.filter { e -> (e.metadata != null) && (e.playbackState != null) }
                .map { e -> MediaInfo.fromMediaController(e) }
        }

        fun refresh(context: Context) {
            updateSessions(context)
        }

        fun setEventSink(context: Context, events: EventChannel.EventSink?) {
            eventSink = events
            updateSessions(context)
        }

        private fun getControlsForPackage(packageName: String) : MediaController.TransportControls {
            val controller = ongoingMediaSessions[packageName] ?: throw Exception("So etwas passiert nicht hier!!!")
            return controller.transportControls
        }

        fun play(packageName: String) {
            getControlsForPackage(packageName).play()
        }

        fun pause(packageName: String) {
            getControlsForPackage(packageName).pause()
        }

        fun seekTo(packageName: String, position: Long) {
            getControlsForPackage(packageName).seekTo(position)
        }

        fun stop(packageName: String) {
            getControlsForPackage(packageName).stop()
        }

        fun skipToNext(packageName: String) {
            getControlsForPackage(packageName).skipToNext()
        }

        fun skipToPrevious(packageName: String) {
            getControlsForPackage(packageName).skipToPrevious()
        }

        fun fastForward(packageName: String) {
            getControlsForPackage(packageName).fastForward()
        }

        fun rewind(packageName: String) {
            getControlsForPackage(packageName).rewind()
        }

        fun prepare(packageName: String) {
            getControlsForPackage(packageName).prepare()
        }

        fun setPlaybackSpeed(packageName: String, speed: Float) {
            getControlsForPackage(packageName).setPlaybackSpeed(speed)
        }

        fun playFromMediaID(packageName: String, mediaID: String) {
            getControlsForPackage(packageName).playFromMediaId(mediaID, null)
        }
    }
}