part of '../structures.dart';

/*class DetectedPlayerData {
  final RecognisedPlayer player;
  
  /// No need from now on
  final NotificationEvent latestEvent;

  const DetectedPlayerData({
    required this.player,
    required this.latestEvent,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DetectedPlayerData && other.player == player;
  }

  @override
  int get hashCode => player.hashCode;

  Future<void> setState(ActivityState state) async {
    if (state == ActivityState.playing) {
      await play();
    } else {
      await pause();
    }
  }

  Future<void> play() async {
    await player.actions.play(latestEvent);
  }

  Future<void> pause() async {
    await player.actions.pause(latestEvent);
  }

  Future<void> previous() async {
    await player.actions.previous(latestEvent);
  }

  Future<void> next() async {
    await player.actions.next(latestEvent);
  }

  Future<void> skipToStart() async {
    await player.actions.skipToStart(latestEvent);
  }

  Future<PlayerStateData> getPlayerStateData() {
    return player.stateExtractor.playerStateData(latestEvent);
  }

  Future<PlayerData> getPlayerData() {
    return player.getPlayerData(
      event: latestEvent,
    );
  }

  Future<ResolvedPlayerData> resolve() async {
    final PlayerData playerData = await getPlayerData();
    final ResolvedPlayerData result = ResolvedPlayerData(
      latestEvent: latestEvent,
      player: player,
      playerData: playerData,
    );
    return result;
  }
}*/

class DetectedPlayerData {
  final RecognisedPlayer player;

  final PlayerMediaInfo mediaInfo;

  const DetectedPlayerData({
    required this.player,
    required this.mediaInfo,
  });

  @mustCallSuper
  @override
  bool operator ==(covariant DetectedPlayerData other) {
    if (identical(this, other)) return true;

    return other.player == player && other.mediaInfo == mediaInfo;
  }

  @mustCallSuper
  @override
  int get hashCode => player.hashCode ^ mediaInfo.hashCode;

  @override
  String toString() =>
      'DetectedPlayerData(player: $player, mediaInfo: $mediaInfo)';

  Future<ResolvedPlayerData> resolve() async {
    final SongBase? resolvedSong = await DatabaseHelper.getMatchedSong(
      mediaInfo.playerDetectedSong,
    );

    final SongBase? resolvedAlbumArt = await DatabaseHelper.getMatchedAlbumArt(
      mediaInfo.playerDetectedSong,
    );

    final ResolvedPlayerData result = ResolvedPlayerData(
      player: player,
      mediaInfo: mediaInfo,
      resolvedSong: resolvedSong,
      resolvedAlbumArt: resolvedAlbumArt,
    );
    return result;
  }
}
