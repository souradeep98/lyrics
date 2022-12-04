part of structures;

/// Package of abstract methods to generate [PlayerData] and allows doing actions
abstract class RecognisedPlayer {
  String iconAsset(LogoColorType type);

  String iconFullAsset(LogoColorType type);

  String get playerName;

  String get packageName;

  final PlayerStateDataExtractor stateExtractor;

  final PlayerActions actions;

  const RecognisedPlayer({
    required this.stateExtractor,
    required this.actions,
  });

  Future<PlayerData> getPlayerData({
    required NotificationEvent event,
  }) async {
    return PlayerData(
      playerName: playerName,
      packageName: packageName,
      iconAsset: iconAsset,
      iconFullAsset: iconFullAsset,
      state: await stateExtractor.playerStateData(event),
    );
  }

  bool isMediaPlayerNotification(NotificationEvent event);
}

enum LogoColorType {
  white,
  black,
  color;
}

/// A class to extract data or [PlayerStateData] of currently playing media and it's state
abstract class PlayerStateDataExtractor {
  const PlayerStateDataExtractor();

  String songName(NotificationEvent event);
  String singerName(NotificationEvent event);
  String albumName(NotificationEvent event);
  ActivityState state(NotificationEvent event);

  Uint8List albumCoverArt(NotificationEvent event);

  int timeStamp(NotificationEvent event);

  Future<PlayerStateData> playerStateData(NotificationEvent event) async {
    final SongBase playerSong = SongBase(
      songName: songName(event),
      singerName: singerName(event),
      albumName: albumName(event),
    );
    final resolvedSong = await DatabaseHelper.getMatchedSong(playerSong);
    return PlayerStateData(
      resolvedSong: resolvedSong,
      playerDetectedSong: playerSong,
      albumCoverArt: albumCoverArt(event),
      state: state(event),
      timeStamp: timeStamp(event),
    );
  }
}

abstract class PlayerActions {
  const PlayerActions();

  Future<void> pause(NotificationEvent event);

  Future<void> play(NotificationEvent event);

  Future<void> next(NotificationEvent event);

  Future<void> previous(NotificationEvent event);

  Future<void>? skipToStart(NotificationEvent event);
}
