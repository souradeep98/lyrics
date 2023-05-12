part of '../structures.dart';

enum ActivityState {
  paused,
  playing;

  String get prettyName {
    switch (this) {
      case ActivityState.playing:
        return "Playing";
      case ActivityState.paused:
        return "Paused";
    }
  }

  ActivityState get opposite {
    switch (this) {
      case ActivityState.playing:
        return ActivityState.paused;
      case ActivityState.paused:
        return ActivityState.playing;
    }
  }
}

class PlayerStateData {
  final ActivityState state;
  final Uint8List albumCoverArt;
  final int timeStamp;
  final SongBase? resolvedSong;
  final SongBase? resolvedAlbumArt;
  final SongBase playerDetectedSong;
  final bool isSongResolved;

  const PlayerStateData({
    required this.resolvedSong,
    required this.resolvedAlbumArt,
    required this.state,
    required this.albumCoverArt,
    required this.timeStamp,
    required this.playerDetectedSong,
  }) : isSongResolved = resolvedSong != null;

  bool isSame(PlayerStateData? other) {
    return (other != null) && (super == other) && (other.state == state);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is PlayerStateData) {
      return other.state == state && other.timeStamp == timeStamp;
    }

    return false;
  }

  /*SongBase get base => SongBase(
        albumName: albumName,
        singerName: singerName,
        songName: songName,
      );*/

  @override
  int get hashCode {
    return state.hashCode ^ albumCoverArt.hashCode ^ timeStamp.hashCode;
  }

  @override
  String toString() {
    return 'PlayerStateData(\n\tsong: $resolvedSong,\n\tstate: ${state.prettyName},\n\ttimeStamp: $timeStamp\n)';
  }
}
