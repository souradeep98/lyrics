package com.lyrics.app

import android.content.ComponentName
import android.content.Context
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSession
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.Bundle
import io.flutter.Log
import io.flutter.plugin.common.EventChannel

class MediaSessionListener {
    private class OnActiveSessionChangedListenerClass(val context: Context) : MediaSessionManager.OnActiveSessionsChangedListener {
        override fun onActiveSessionsChanged(mediaControllers: MutableList<MediaController>?) {
            updateSessions(context, mediaControllers)
        }
    }

    private class MediaSessionListenerCallback(val context: Context, val packageName: String) : MediaController.Callback() {
        val tag = "MediaSessionListenerCallback - $packageName"

        override fun onAudioInfoChanged(info: MediaController.PlaybackInfo?) {
            Log.i(tag, "onAudioInfoChanged")
            super.onAudioInfoChanged(info)
            updateSessions(context)
        }

        override fun onExtrasChanged(extras: Bundle?) {
            Log.i(tag, "onExtrasChanged")
            super.onExtrasChanged(extras)
        }

        override fun onMetadataChanged(metadata: MediaMetadata?) {
            Log.i(tag, "onMetadataChanged")
            super.onMetadataChanged(metadata)
            updateSessions(context)
        }

        override fun onPlaybackStateChanged(state: PlaybackState?) {
            Log.i(tag, "onPlaybackStateChanged")
            super.onPlaybackStateChanged(state)
            updateSessions(context)
        }

        override fun onQueueChanged(queue: MutableList<MediaSession.QueueItem>?) {
            Log.i(tag, "onQueueChanged")
            super.onQueueChanged(queue)
        }

        override fun onQueueTitleChanged(title: CharSequence?) {
            Log.i(tag, "onQueueTitleChanged")
            super.onQueueTitleChanged(title)
        }

        override fun onSessionDestroyed() {
            Log.i(tag, "onSessionDestroyed")
            super.onSessionDestroyed()
        }

        override fun onSessionEvent(event: String, extras: Bundle?) {
            Log.i(tag, "onSessionEvent - $event")
            super.onSessionEvent(event, extras)
        }
    }

    companion object {
        private const val tag = "MediaSessionListener"

        @JvmStatic
        private var isInitialized: Boolean = false

        @JvmStatic
        private var eventSink: EventChannel.EventSink? = null

        @JvmStatic
        private var mediaSessionManager: MediaSessionManager? = null

        @JvmStatic
        private val ongoingMediaSessions = mutableMapOf<String, MediaController>()

        @JvmStatic
        private val ongoingMediaInfo = mutableMapOf<String, MediaInfo>()

        @JvmStatic
        private lateinit var onActiveSessionChangedListener: MediaSessionManager.OnActiveSessionsChangedListener

        @JvmStatic
        private lateinit var mediaSessionListenerCallbacks: MutableMap<String, MediaController.Callback>

        @JvmStatic
        private lateinit var mediaNotificationListenerCN: ComponentName

        fun initialize(context: Context) {
            if (isInitialized) {
                return
            }

            if (!MediaNotificationListener.isNotificationAccessPermissionGiven(context)) {
                //MediaNotificationListener.openNotificationAccessPermissionSettings(context)
                return
            }

            onActiveSessionChangedListener = OnActiveSessionChangedListenerClass(context)

            mediaSessionListenerCallbacks = mutableMapOf()

            Log.i(tag, "Getting MediaSessionManager")

            mediaSessionManager = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager

            Log.i(tag, "Got MediaSessionManager")

            mediaNotificationListenerCN = ComponentName(context,
                MediaNotificationListener::class.java.name
            )

            Log.i(tag, "Adding OnActiveSessionsChangedListener")

            mediaSessionManager!!.addOnActiveSessionsChangedListener(onActiveSessionChangedListener, mediaNotificationListenerCN)

            isInitialized = true

            updateSessions(context)
        }

        fun dispose() {
            mediaSessionManager?.removeOnActiveSessionsChangedListener(onActiveSessionChangedListener)
        }

        private fun updateSessions(context: Context, mediaControllers: MutableList<MediaController>? = null, notifyEventSink: Boolean = true) {
            if (!isInitialized) {
                initialize(context)
            }

            val newMediaControllers = (mediaControllers ?: mediaSessionManager!!.getActiveSessions(mediaNotificationListenerCN)).filter { e -> (e.metadata != null) && (e.playbackState != null) }

            Log.i(tag, "Called updateSessions with: ${newMediaControllers.size}")

            for (x in ongoingMediaSessions) {
                x.value.unregisterCallback(mediaSessionListenerCallbacks[x.key]!!)
                //mediaSessionListenerCallbacks.remove(x.key)
            }
            mediaSessionListenerCallbacks.clear()

            ongoingMediaSessions.clear()

            ongoingMediaInfo.clear()

            for (x in newMediaControllers) {
                if (Constants.recognisedPlayers.contains(x.packageName)) {
                    val callback = MediaSessionListenerCallback(context, x.packageName)
                    x.registerCallback(callback)
                    mediaSessionListenerCallbacks[x.packageName] = callback
                    ongoingMediaSessions[x.packageName] = x

                    val mediaInfo = MediaInfo.fromMediaController(x)
                    ongoingMediaInfo[x.packageName] = mediaInfo
                }
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
            return ongoingMediaInfo.values.toList()
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