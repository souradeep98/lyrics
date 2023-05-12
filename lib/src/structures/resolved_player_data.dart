part of '../structures.dart';

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
