library recognized_players;

import 'dart:typed_data';

import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:lyrics/src/structures.dart';

part 'recognized_players/jiosaavn.dart';
part 'recognized_players/spotify.dart';

abstract class RecognisedPlayers {
  static const Map<String, RecognisedPlayer> recognisedPlayers = {
    "com.jio.media.jiobeats": JioSaavnPlayer(),
    "com.spotify.music": SpotifyPlayer(),
  };

  static bool isRecognised(NotificationEvent event) =>
      recognisedPlayers.containsKey(event.packageName) && getPlayer(event)!.isMediaPlayerNotification(event);

  static RecognisedPlayer? getPlayer(NotificationEvent event) =>
      recognisedPlayers[event.packageName];

  static Future<PlayerStateData?> getPlayerStateData(
    NotificationEvent event,
  ) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.stateExtractor.playerStateData(event);
  }

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

  static Future<void> play(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.play(event);
  }

  static Future<void> pause(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.pause(event);
  }

  static Future<void> previous(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.previous(event);
  }

  static Future<void> next(NotificationEvent event) async {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return;
    }

    await player.actions.next(event);
  }

  static String? iconAsset(NotificationEvent event, LogoColorType type) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.iconAsset(type);
  }

  static String? iconFullAsset(NotificationEvent event, LogoColorType type) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.iconFullAsset(type);
  }

  static String? playerName(NotificationEvent event) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.playerName;
  }
}
