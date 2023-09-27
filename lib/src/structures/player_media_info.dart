part of '../structures.dart';

class PlayerMediaInfo {
  final ActivityState state;
  final Uint8List albumCoverArt;
  final SongBase playerDetectedSong;

  final DateTime occurrenceTime;

  final Duration duration;

  const PlayerMediaInfo({
    required this.state,
    required this.albumCoverArt,
    required this.playerDetectedSong,
    required this.occurrenceTime,
    required this.duration,
  });

  @override
  bool operator ==(covariant PlayerMediaInfo other) {
    if (identical(this, other)) return true;
  
    return 
      other.state == state &&
      other.albumCoverArt == albumCoverArt &&
      other.playerDetectedSong == playerDetectedSong &&
      other.occurrenceTime == occurrenceTime &&
      other.duration == duration;
  }

  @override
  int get hashCode {
    return state.hashCode ^
      albumCoverArt.hashCode ^
      playerDetectedSong.hashCode ^
      occurrenceTime.hashCode ^
      duration.hashCode;
  }

  @override
  String toString() {
    return 'PlayerMediaInfo(state: $state, albumCoverArt: $albumCoverArt, playerDetectedSong: $playerDetectedSong, occurrenceTime: $occurrenceTime, duration: $duration)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.index,
      'albumCoverArt': albumCoverArt,
      'occurrenceTime': occurrenceTime.toIso8601String(),
      'duration': duration.inMilliseconds,
      ...playerDetectedSong.toMediaInfoMap(),
    };
  }

  factory PlayerMediaInfo.fromMap(Map<String, dynamic> map) {
    return PlayerMediaInfo(
      state: ActivityState.fromMediaInfoStateInt(map['state'] as int),
      albumCoverArt: map['songAlbumArt'] as Uint8List,
      playerDetectedSong: SongBase.fromMediaInfoMap(map),
      occurrenceTime: DateTime.parse(map['occurrenceTime'] as String),
      duration: Duration(milliseconds: map['duration'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerMediaInfo.fromJson(String source) => PlayerMediaInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
