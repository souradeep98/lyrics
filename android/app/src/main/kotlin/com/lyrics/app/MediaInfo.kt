package com.lyrics.app

import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import io.flutter.Log
import java.io.ByteArrayOutputStream
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class MediaInfo(
    val packageName: String,
    val songName: String,
    val songArtist: String,
    val songAlbum: String,
    val songAlbumArt: Bitmap?,
    val position: Long,
    val occurrenceTime: Long = System.currentTimeMillis(),
    val duration: Long,
    val state: Int,
    val mediaID: String?,
) {
    companion object {
        fun fromMediaController(controller: MediaController): MediaInfo {
            val metaData = controller.metadata ?: throw Exception("Es kann hier nie passiert!!!")
            val playbackState = controller.playbackState ?: throw Exception("Es kann hier nie passiert!!!")
            return MediaInfo(
                controller.packageName ?: "",
                metaData.getString(MediaMetadata.METADATA_KEY_TITLE) ?: "",
                metaData.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: "",
                metaData.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: "",
                metaData.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART),
                playbackState.position,
                System.currentTimeMillis(),
                metaData.getLong(MediaMetadata.METADATA_KEY_DURATION),
                playbackState.state,
                metaData.getString(MediaMetadata.METADATA_KEY_MEDIA_ID) ?: "",
            )
        }

        fun fromJson(json: Map<String, Any>): MediaInfo {
            val iso8601Format = DateTimeFormatter.ofPattern("uuuu-MM-dd'T'HH:mm:ss.SSSX")
            return MediaInfo(
                json["packageName"] as String,
                json["songName"] as String,
                json["songArtist"] as String,
                json["songAlbum"] as String,
                json["songAlbumArt"] as Bitmap,
                json["position"] as Long,
                json["occurrenceTime"] as Long,
                json["duration"] as Long,
                json["state"] as Int,
                json["mediaID"] as String?,
            )
        }
    }

    fun toJson(): Map<String, Any?> {
        var songAlbumArtBytesArray: ByteArray? = null

        if (songAlbumArt != null) {
            val stream = ByteArrayOutputStream()
            songAlbumArt.compress(Bitmap.CompressFormat.PNG, 100, stream)
            songAlbumArtBytesArray = stream.toByteArray()
        }

        return mapOf(
            "packageName" to packageName,
            "songName" to songName,
            "songArtist" to songArtist,
            "songAlbum" to songAlbum,
            "songAlbumArt" to songAlbumArtBytesArray,
            "position" to position,
            "occurrenceTime" to occurrenceTime,
            "duration" to duration,
            "state" to state,
            "mediaID" to mediaID,
        )
    }

    override fun toString(): String {
        return "MediaInfo(${toJson()})"
    }

    private fun printControllerInfo(controller: MediaController) {
        //controller.metadata
        //controller.playbackInfo
        //controller.transportControls
        //controller.playbackState

        Log.i("MediaInfo", " ")

        Log.i("MediaInfo", "Constructing MediaInfo for ${controller.packageName}")

        Log.i("MediaInfo - playbackPosition", (controller.playbackState?.position ?: 0).toString())
        val metaData = controller.metadata

        Log.i("MediaInfo", if (metaData != null) "Got MetaData" else "MetaData is null")

        Log.i("MediaInfo", if (controller.playbackInfo != null) "Got PlaybackInfo" else "PlaybackInfo is null")

        Log.i("MediaInfo", if (controller.transportControls != null) "Got TransportControls" else "TransportControls is null")

        Log.i("MediaInfo", if (controller.playbackState != null) "Got PlaybackState" else "PlaybackState is null")

        printMetaData(metaData)
    }

    private fun printMetaData(metaData: MediaMetadata?) {
        if (metaData == null) {
            //Log.i("MediaInfo", "MetaData is null")
            return
        }

        Log.i("MediaInfo", "Printing metadata below...")
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_ALBUM)

        printMetaDataIfBitmapPresent(metaData, MediaMetadata.METADATA_KEY_ALBUM_ART)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_ALBUM_ARTIST)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_ALBUM_ART_URI)

        printMetaDataIfBitmapPresent(metaData, MediaMetadata.METADATA_KEY_ART)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_ARTIST)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_ART_URI)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_AUTHOR)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_BT_FOLDER_TYPE)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_COMPILATION)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_COMPOSER)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DATE)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DISC_NUMBER)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DISPLAY_DESCRIPTION)

        printMetaDataIfBitmapPresent(metaData, MediaMetadata.METADATA_KEY_DISPLAY_ICON)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DISPLAY_ICON_URI)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DISPLAY_TITLE)

        printMetaDataLongAttribute(metaData, MediaMetadata.METADATA_KEY_DURATION)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_GENRE)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_MEDIA_ID)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_MEDIA_URI)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_NUM_TRACKS)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_RATING)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_DATE)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_TITLE)
        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_TRACK_NUMBER)

        printMetaDataRatingAttribute(metaData, MediaMetadata.METADATA_KEY_USER_RATING)

        printMetaDataStringAttribute(metaData, MediaMetadata.METADATA_KEY_WRITER)

        printMetaDataLongAttribute(metaData, MediaMetadata.METADATA_KEY_YEAR)
    }

    private fun printMetaDataStringAttribute(metaData: MediaMetadata, attribute: String) {
        val result = metaData.getString(attribute)

        if (result != null) {
            Log.i("MediaInfo $attribute (String)", result)
        }

    }

    private fun printMetaDataLongAttribute(metaData: MediaMetadata, attribute: String) {
        Log.i("MediaInfo $attribute (Long)", (metaData.getLong(attribute)).toString())
    }

    private fun printMetaDataIfBitmapPresent(metaData: MediaMetadata, attribute: String) {
        val result = metaData.getBitmap(attribute) != null
        Log.i("MediaInfo $attribute (Bitmap)", if (result) {
            "Present"
        } else "Absent")
    }

    private fun printMetaDataRatingAttribute(metaData: MediaMetadata, attribute: String) {
        Log.i("MediaInfo $attribute (Rating)", if (metaData.getRating(attribute) != null) "Present" else "Absent")
    }
}

