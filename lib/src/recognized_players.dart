library recognized_players;

import 'package:lyrics/src/structures.dart';

part 'recognized_players/jiosaavn.dart';
part 'recognized_players/spotify.dart';

abstract class RecognisedPlayers {
  @pragma("vm:entry-point")
  static const Map<String, RecognisedPlayer> recognisedPlayers = {
    JioSaavnPlayer.kPackageName: JioSaavnPlayer(),
    SpotifyPlayer.kPackageName: SpotifyPlayer(),
  };

  /*@pragma("vm:entry-point")
  static bool isPackageRecognised(NotificationEvent event) =>
      recognisedPlayers.containsKey(event.packageName);

  @pragma("vm:entry-point")
  static RecognisedPlayer? getPlayer(NotificationEvent event) {
    if (!isPackageRecognised(event)) {
      return null;
    }
    final RecognisedPlayer? player = recognisedPlayers[event.packageName];

    if (player == null) {
      return null;
    }

    return player.isMediaPlayerNotification(event) ? player : null;
  }*/

  /// New
  @pragma("vm:entry-point")
  static bool isPackageRecognised(String packageName) =>
      recognisedPlayers.containsKey(packageName);

  /// New
  @pragma("vm:entry-point")
  static RecognisedPlayer? getPlayer(String packageName) {
    if (!isPackageRecognised(packageName)) {
      return null;
    }
    final RecognisedPlayer? player = recognisedPlayers[packageName];

    if (player == null) {
      return null;
    }

    return player;
  }

  /*@pragma("vm:entry-point")
  static Future<PlayerStateData?> getPlayerStateData(
    NotificationEvent event,
  ) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.stateExtractor.playerStateData(event);
  }

  @pragma("vm:entry-point")
  static Future<PlayerData?> getPlayerData({
    required NotificationEvent event,
  }) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.getPlayerData(
      event: event,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> play(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.play(event);
  }

  @pragma("vm:entry-point")
  static Future<void> pause(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.pause(event);
  }

  @pragma("vm:entry-point")
  static Future<void> previous(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.previous(event);
  }

  @pragma("vm:entry-point")
  static Future<void> next(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.next(event);
  }

  @pragma("vm:entry-point")
  static String? iconAsset(NotificationEvent event, LogoColorType type) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.getIconAsset(type);
  }

  @pragma("vm:entry-point")
  static String? iconFullAsset(NotificationEvent event, LogoColorType type) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.getFullIconAsset(type);
  }

  @pragma("vm:entry-point")
  static String? playerName(NotificationEvent event) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.playerName;
  }*/
}
