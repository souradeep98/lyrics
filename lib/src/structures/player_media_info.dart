part of '../structures.dart';

class PlayerMediaInfo {
  final ActivityState state;
  final Uint8List albumCoverArt;
  final SongBase playerDetectedSong;

  /// Time of this media session event
  final DateTime occurrenceTime;

  /// Total duration of the media
  final Duration totalDuration;

  final Duration currentPosition;

  final String mediaID;

  const PlayerMediaInfo({
    required this.state,
    required this.albumCoverArt,
    required this.playerDetectedSong,
    required this.occurrenceTime,
    required this.totalDuration,
    required this.currentPosition,
    required this.mediaID,
  });

  @override
  bool operator ==(covariant PlayerMediaInfo other) {
    if (identical(this, other)) return true;
  
    return 
      other.state == state &&
      other.albumCoverArt == albumCoverArt &&
      other.playerDetectedSong == playerDetectedSong &&
      other.occurrenceTime == occurrenceTime &&
      other.totalDuration == totalDuration &&
      other.currentPosition == currentPosition &&
      other.mediaID == mediaID;
  }

  @override
  int get hashCode {
    return state.hashCode ^
      albumCoverArt.hashCode ^
      playerDetectedSong.hashCode ^
      occurrenceTime.hashCode ^
      totalDuration.hashCode ^
      currentPosition.hashCode ^
      mediaID.hashCode;
  }

  @override
  String toString() {
    return 'PlayerMediaInfo(state: $state, playerDetectedSong: $playerDetectedSong, occurrenceTime: $occurrenceTime, totalDuration: $totalDuration, currentPosition: $currentPosition, mediaID: $mediaID)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.index,
      'albumCoverArt': albumCoverArt,
      'occurrenceTime': occurrenceTime.millisecondsSinceEpoch,
      'duration': totalDuration.inMilliseconds,
      'mediaID': mediaID,
      'position': currentPosition.inMilliseconds,
      ...playerDetectedSong.toMediaInfoMap(),
    };
  }

  factory PlayerMediaInfo.fromMap(
    Map<String, dynamic> map, {
    SongBase Function(Map<String, dynamic> map) songBaseGetterFromMap =
        SongBase.fromMediaInfoMap,
  }) {
    return PlayerMediaInfo(
      state: ActivityState.fromMediaInfoStateInt(map['state'] as int),
      albumCoverArt: map['songAlbumArt'] as Uint8List,
      playerDetectedSong: songBaseGetterFromMap(map),
      occurrenceTime: DateTime.fromMillisecondsSinceEpoch(map['occurrenceTime'] as int),
      totalDuration: Duration(milliseconds: map['duration'] as int),
      mediaID: map['mediaID'] as String,
      currentPosition: Duration(milliseconds: map['position'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerMediaInfo.fromJson(String source) =>
      PlayerMediaInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
