library recognized_players;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:lyrics/src/structures.dart';

part 'recognized_players/jiosaavn.dart';
part 'recognized_players/spotify.dart';

abstract class RecognisedPlayers {
  @pragma("vm:entry-point")
  static const Map<String, RecognisedPlayer> recognisedPlayers = {
    "com.jio.media.jiobeats": JioSaavnPlayer(),
    "com.spotify.music": SpotifyPlayer(),
  };

  @pragma("vm:entry-point")
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
  }

  @pragma("vm:entry-point")
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

    return player.iconAsset(type);
  }

  @pragma("vm:entry-point")
  static String? iconFullAsset(NotificationEvent event, LogoColorType type) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.iconFullAsset(type);
  }

  @pragma("vm:entry-point")
  static String? playerName(NotificationEvent event) {
    final RecognisedPlayer? player = getPlayer(event);

    if (player == null) {
      return null;
    }

    return player.playerName;
  }
}
