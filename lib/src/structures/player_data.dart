part of '../structures.dart';
/*
typedef PlayerLogoGetter = String Function(LogoColorType colorType);

/// Not needed in new
class PlayerData {
  final String playerName;
  final String packageName;
  final PlayerLogoGetter iconAsset;
  final PlayerLogoGetter iconFullAsset;
  final PlayerStateData state;

  const PlayerData({
    required this.playerName,
    required this.packageName,
    required this.iconAsset,
    required this.iconFullAsset,
    required this.state,
  });

  bool get isSongResolved => state.isSongResolved;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerData &&
        other.playerName == playerName &&
        other.packageName == packageName &&
        other.iconAsset == iconAsset &&
        other.iconFullAsset == iconFullAsset &&
        other.state == state;
  }

  @override
  int get hashCode {
    return playerName.hashCode ^
        packageName.hashCode ^
        iconAsset.hashCode ^
        iconFullAsset.hashCode ^
        state.hashCode;
  }
}*/
