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

  factory ActivityState.fromInt(int x) {
    return switch (x) {
      0 => paused,
      1 => playing,
      _ => throw "Unknown state!",
    };
  }

  factory ActivityState.fromMediaInfoStateInt(int x) {
    return switch (x) {
      3 => playing,
      _ => paused,
    };
  }
}

/*
/// No need in new
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is PlayerStateData) {
      return other.state == state && other.timeStamp == timeStamp;
    }

    return false;
  }

  @override
  int get hashCode {
    return state.hashCode ^ albumCoverArt.hashCode ^ timeStamp.hashCode;
  }

  @override
  String toString() {
    return 'PlayerStateData(\n\tsong: $resolvedSong,\n\tstate: ${state.prettyName},\n\ttimeStamp: $timeStamp\n)';
  }
}
*/
