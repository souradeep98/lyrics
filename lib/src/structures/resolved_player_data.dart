part of '../structures.dart';

/*
class ResolvedPlayerData extends DetectedPlayerData {
  final PlayerData playerData;

  const ResolvedPlayerData({
    required super.latestEvent,
    required super.player,
    required this.playerData,
  });

  @override
  bool operator ==(covariant ResolvedPlayerData other) {
    if (identical(this, other)) return true;

    return super == other && other.playerData == playerData;
  }

  @override
  int get hashCode => playerData.hashCode ^ super.hashCode;

  bool get isSongResolved => playerData.isSongResolved;
}
*/

class ResolvedPlayerData extends DetectedPlayerData {
  final SongBase? resolvedSong;
  final SongBase? resolvedAlbumArt;

  const ResolvedPlayerData({
    required super.player,
    required super.mediaInfo,
    this.resolvedSong,
    this.resolvedAlbumArt,
  });

  bool get isSongResolved => resolvedSong != null;

  @override
  bool operator ==(covariant ResolvedPlayerData other) {
    if (identical(this, other)) return true;
  
    return 
      other.resolvedSong == resolvedSong &&
      other.resolvedAlbumArt == resolvedAlbumArt && super == other;
  }

  @override
  int get hashCode => resolvedSong.hashCode ^ resolvedAlbumArt.hashCode ^ super.hashCode;

  @override
  String toString() => 'ResolvedPlayerData(resolvedSong: $resolvedSong, resolvedAlbumArt: $resolvedAlbumArt)';
}
