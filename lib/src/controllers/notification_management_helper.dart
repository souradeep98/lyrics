part of '../controllers.dart';

abstract final class NotificationManagementHelper {
  @pragma("vm:entry-point")
  static final Map<String, int> _ids = {};

  @pragma("vm:entry-point")
  static AwesomeNotifications? _awesomeNotifications;

  @pragma("vm:entry-point")
  static bool get isInitialized => _awesomeNotifications != null;

  @pragma("vm:entry-point")
  static Future<bool> hasPermission() async {
    return (await _awesomeNotifications?.isNotificationAllowed()) ?? false;
  }

  @pragma("vm:entry-point")
  static Future<void> requestPermission() async {
    await _awesomeNotifications?.requestPermissionToSendNotifications();
  }

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    _awesomeNotifications = AwesomeNotifications();

    await _awesomeNotifications!.initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: NotificationKeys.musicActivityNotifications.key,
          channelKey: NotificationKeys
              .musicActivityNotifications.channels.viewLyricsNotifications.key,
          channelName: NotificationKeys
              .musicActivityNotifications.channels.viewLyricsNotifications.name,
          channelDescription: NotificationKeys.musicActivityNotifications
              .channels.viewLyricsNotifications.description,
          playSound: false,
          enableVibration: false,
          enableLights: false,
        ),
        NotificationChannel(
          channelGroupKey: NotificationKeys.musicActivityNotifications.key,
          channelKey: NotificationKeys
              .musicActivityNotifications.channels.addLyricsNotifications.key,
          channelName: NotificationKeys
              .musicActivityNotifications.channels.addLyricsNotifications.name,
          channelDescription: NotificationKeys.musicActivityNotifications
              .channels.addLyricsNotifications.description,
          playSound: false,
          enableVibration: false,
          enableLights: false,
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: NotificationKeys.musicActivityNotifications.key,
          channelGroupName: NotificationKeys.musicActivityNotifications.name,
        ),
      ],
      debug: kDebugMode,
    );
  }

  /*@pragma("vm:entry-point")
  static Future<void> showViewLyricsNotificationFor(
    PlayerData playerData,
  ) async {
    final SongBase song = playerData.state.playerDetectedSong;
    final String title =
        "${song.songName} - ${song.singerName} - ${song.albumName}";
    final String albumArt =
        (await AlbumArtCache.getCachedAlbumArtFilePathForPlayerData(
      playerData,
    ))!;
    final String finalImageString = "file://$albumArt";

    await _awesomeNotifications?.createNotification(
      content: NotificationContent(
        id: _ids[playerData.packageName] ??= _ids.length,
        channelKey: NotificationKeys
            .musicActivityNotifications.channels.viewLyricsNotifications.key,
        title: title,
        body: 'Tap to see lyrics'.translate(),
        category: NotificationCategory.Recommendation,
        //notificationLayout: NotificationLayout.Default,
        largeIcon: finalImageString,
      ),
      /*actionButtons: [
        NotificationActionButton(key: "hello", label: "HI"),
      ],*/
    );
  }

  @pragma("vm:entry-point")
  static Future<void> showAddLyricsNotificationFor(
    PlayerData playerData,
  ) async {
    final SongBase song = playerData.state.playerDetectedSong;
    final String title =
        "${song.songName} - ${song.singerName} - ${song.albumName}";
    final String albumArt =
        (await AlbumArtCache.getCachedAlbumArtFilePathForPlayerData(
      playerData,
    ))!;
    final String finalImageString = "file://$albumArt";

    await _awesomeNotifications?.createNotification(
      content: NotificationContent(
        id: _ids[playerData.packageName] ??= _ids.length,
        channelKey: NotificationKeys
            .musicActivityNotifications.channels.viewLyricsNotifications.key,
        title: title,
        body: "+${'Tap to add lyrics'.translate()}",
        category: NotificationCategory.Recommendation,
        largeIcon: finalImageString,
      ),
    );
  }*/

  @pragma("vm:entry-point")
  static Future<void> showViewLyricsNotificationFor(
    ResolvedPlayerData resolvedPlayerData,
  ) async {
    final SongBase song = resolvedPlayerData.mediaInfo.playerDetectedSong;
    final String title =
        "${song.songName} - ${song.singerName} - ${song.albumName}";
    final String albumArt =
        (await AlbumArtCache.getCachedAlbumArtFilePathForPlayerData(
      resolvedPlayerData,
    ))!;
    final String finalImageString = "file://$albumArt";

    await _awesomeNotifications?.createNotification(
      content: NotificationContent(
        id: _ids[resolvedPlayerData.player.packageName] ??= _ids.length,
        channelKey: NotificationKeys
            .musicActivityNotifications.channels.viewLyricsNotifications.key,
        title: title,
        body: 'Tap to see lyrics'.translate(),
        category: NotificationCategory.Recommendation,
        //notificationLayout: NotificationLayout.Default,
        largeIcon: finalImageString,
      ),
      /*actionButtons: [
        NotificationActionButton(key: "hello", label: "HI"),
      ],*/
    );
  }

  @pragma("vm:entry-point")
  static Future<void> showAddLyricsNotificationFor(
    ResolvedPlayerData resolvedPlayerData,
  ) async {
    final SongBase song = resolvedPlayerData.mediaInfo.playerDetectedSong;
    final String title =
        "${song.songName} - ${song.singerName} - ${song.albumName}";
    final String albumArt =
        (await AlbumArtCache.getCachedAlbumArtFilePathForPlayerData(
      resolvedPlayerData,
    ))!;
    final String finalImageString = "file://$albumArt";

    await _awesomeNotifications?.createNotification(
      content: NotificationContent(
        id: _ids[resolvedPlayerData.player.packageName] ??= _ids.length,
        channelKey: NotificationKeys
            .musicActivityNotifications.channels.viewLyricsNotifications.key,
        title: title,
        body: "+${'Tap to add lyrics'.translate()}",
        category: NotificationCategory.Recommendation,
        largeIcon: finalImageString,
      ),
    );
  }

  @pragma("vm:entry-point")
  static Future<void> removeAllMusicActivityActiveNotification() async {
    await _awesomeNotifications?.cancelNotificationsByGroupKey(
      NotificationKeys.musicActivityNotifications.key,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> showPlayingNotifications() async {
    for (final ResolvedPlayerData resolvedPlayerData
        in MediaInfoListenableHelper.sessions.values) {
      if (resolvedPlayerData.mediaInfo.state == ActivityState.playing) {
        logExceptRelease(
          "Showing notification for player: ${resolvedPlayerData.player.playerName}",
        );
        if (resolvedPlayerData.isSongResolved) {
          await NotificationManagementHelper.showViewLyricsNotificationFor(
            resolvedPlayerData,
          );
        } else {
          await NotificationManagementHelper.showAddLyricsNotificationFor(
            resolvedPlayerData,
          );
        }
      }
    }
  }
}

// resource entry point
abstract class NotificationKeys {
  @pragma("vm:entry-point")
  static const _MusicActivityNotificationGroup musicActivityNotifications =
      _MusicActivityNotificationGroup();
}

// Base Structures
abstract class _NotificationGroup {
  const _NotificationGroup();

  String get key;
  String get name;

  _NotificationChannels get channels;
}

abstract class _NotificationChannels {
  const _NotificationChannels();
}

class _NotificationChannel {
  final int Function() getID;
  final String name;
  final String key;
  final String description;

  const _NotificationChannel({
    required this.getID,
    required this.name,
    required this.key,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _NotificationChannel &&
        other.getID == getID &&
        other.name == name &&
        other.key == key &&
        other.description == description;
  }

  @override
  int get hashCode {
    return getID.hashCode ^ name.hashCode ^ key.hashCode ^ description.hashCode;
  }
}

// Music Activity Notification
class _MusicActivityNotificationGroup extends _NotificationGroup {
  const _MusicActivityNotificationGroup();

  @override
  String get key => "music_activity_notifications";

  @override
  String get name => "Music Activity Notifications";

  @override
  _MusicActivityChannelKeys get channels => const _MusicActivityChannelKeys();
}

class _MusicActivityChannelKeys extends _NotificationChannels {
  const _MusicActivityChannelKeys();

  static int _getViewLyricsID() {
    return 1;
  }

  static int _getAddNotificationID() {
    return 1;
  }

  _NotificationChannel get addLyricsNotifications => const _NotificationChannel(
        getID: _getAddNotificationID,
        key: "add_lyrics_notifications",
        name: "Add Lyrics Notifications",
        description: "Prompt to add lyrics of a Music",
      );

  _NotificationChannel get viewLyricsNotifications =>
      const _NotificationChannel(
        getID: _getViewLyricsID,
        key: "view_lyrics_notifications",
        name: "View Lyrics Notifications",
        description: "Prompt to view lyrics of a Music",
      );
}
