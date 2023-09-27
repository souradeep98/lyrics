part of '../structures.dart';

/*
/// Package of abstract methods to generate [PlayerData] and allows doing actions
abstract class RecognisedPlayer {
  /// No need in new
  final NotificationLables lables;

  String getIconAsset(LogoColorType type);

  String getFullIconAsset(LogoColorType type);

  String get playerName;

  String get packageName;

  /// No need in new
  final PlayerStateDataExtractor stateExtractor;

  /// No need in new
  final PlayerActions actions;

  const RecognisedPlayer({
    required this.stateExtractor,
    required this.actions,
    required this.lables,
  });

  Future<PlayerData> getPlayerData({
    required NotificationEvent event,
  }) async {
    return PlayerData(
      playerName: playerName,
      packageName: packageName,
      iconAsset: getIconAsset,
      iconFullAsset: getFullIconAsset,
      state: await stateExtractor.playerStateData(event),
    );
  }

  bool isMediaPlayerNotification(NotificationEvent event);
}

/// A class to extract data or [PlayerStateData] of currently playing media and it's state
/// No need in new
abstract class PlayerStateDataExtractor extends LogHelper {
  final NotificationLables lables;
  const PlayerStateDataExtractor({required this.lables});

  String songName(NotificationEvent event);
  String singerName(NotificationEvent event);
  String albumName(NotificationEvent event);
  ActivityState state(NotificationEvent event);

  Uint8List albumCoverArt(NotificationEvent event);

  int timeStamp(NotificationEvent event);

  MatchIgnoreParameters get songMatchIgnoreParameter =>
      const MatchIgnoreParameters.song();

  MatchIgnoreParameters get albumArtSearchIgnoreParameters =>
      const MatchIgnoreParameters.albumArt();

  Future<PlayerStateData> playerStateData(NotificationEvent event) async {
    final SongBase playerSong = SongBase(
      songName: songName(event),
      singerName: singerName(event),
      albumName: albumName(event),
      languageCode: "",
    );
    final SongBase? resolvedSong = await DatabaseHelper.getMatchedSong(
      playerSong,
      matchIgnoreParameters: songMatchIgnoreParameter,
    );
    final SongBase? resolvedAlbumArt = await DatabaseHelper.getMatchedAlbumArt(
      playerSong,
      matchIgnoreParameters: albumArtSearchIgnoreParameters,
    );
    return PlayerStateData(
      resolvedSong: resolvedSong,
      resolvedAlbumArt: resolvedAlbumArt,
      playerDetectedSong: playerSong,
      albumCoverArt: albumCoverArt(event),
      state: state(event),
      timeStamp: timeStamp(event),
    );
  }
}

/// No need in new
abstract class NotificationLables {
  const NotificationLables();

  String get play;
  String get pause;
  String get previous;
  String get next;
}

/// No need in new
abstract class PlayerActions extends LogHelper {
  final NotificationLables lables;
  const PlayerActions({required this.lables});

  Future<void> pause(NotificationEvent event);

  Future<void> play(NotificationEvent event);

  Future<void> next(NotificationEvent event);

  Future<void> previous(NotificationEvent event);

  Future<void>? skipToStart(NotificationEvent event);
}*/

enum LogoColorType {
  white,
  black,
  color;
}

/// New
abstract class RecognisedPlayer {
  const RecognisedPlayer();

  String getIconAsset(LogoColorType type);

  String getFullIconAsset(LogoColorType type);

  String get playerName;

  String get packageName;

  Future<void> setState(ActivityState state) async {
    switch (state) {
      case ActivityState.paused:
        await pause();
      case ActivityState.playing:
        await play();
    }
  }

  Future<void> play() async {
    await PlatformChannelManager.mediaSessions.controls.play(packageName);
  }

  Future<void> pause() async {
    await PlatformChannelManager.mediaSessions.controls.pause(packageName);
  }

  Future<void> skipToNext() async {
    await PlatformChannelManager.mediaSessions.controls.skipToNext(packageName);
  }

  Future<void> skipToPrevious() async {
    await PlatformChannelManager.mediaSessions.controls
        .skipToPrevious(packageName);
  }

  Future<void> fastForward() async {
    await PlatformChannelManager.mediaSessions.controls
        .fastForward(packageName);
  }

  Future<void> rewind() async {
    await PlatformChannelManager.mediaSessions.controls.rewind(packageName);
  }

  Future<void> prepare() async {
    await PlatformChannelManager.mediaSessions.controls.prepare(packageName);
  }

  Future<void> stop() async {
    await PlatformChannelManager.mediaSessions.controls.stop(packageName);
  }

  Future<void> seekTo(Duration duration) async {
    await PlatformChannelManager.mediaSessions.controls
        .seekTo(packageName, duration);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await PlatformChannelManager.mediaSessions.controls
        .setPlaybackSpeed(packageName, speed);
  }
}

class MatchIgnoreParameters {
  final bool songName;
  final bool albumName;
  final bool singerName;

  const MatchIgnoreParameters({
    required this.songName,
    required this.albumName,
    required this.singerName,
  });

  const MatchIgnoreParameters.song({
    this.songName = false,
    this.albumName = true,
    this.singerName = false,
  });

  const MatchIgnoreParameters.albumArt({
    this.songName = true,
    this.albumName = false,
    this.singerName = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchIgnoreParameters &&
        other.songName == songName &&
        other.albumName == albumName &&
        other.singerName == singerName;
  }

  @override
  int get hashCode =>
      songName.hashCode ^ albumName.hashCode ^ singerName.hashCode;

  MatchIgnoreParameters copyWith({
    bool? songName,
    bool? albumName,
    bool? singerName,
  }) {
    return MatchIgnoreParameters(
      songName: songName ?? this.songName,
      albumName: albumName ?? this.albumName,
      singerName: singerName ?? this.singerName,
    );
  }

  @override
  String toString() =>
      'MatchIgnoreParameters(songName: $songName, albumName: $albumName, singerName: $singerName)';
}
