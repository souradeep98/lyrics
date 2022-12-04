part of recognized_players;

class SpotifyPlayer extends RecognisedPlayer {
  const SpotifyPlayer()
      : super(
          stateExtractor: const JioSaavnDataExtractor(),
          actions: const JioSaavnPlayerActions(),
        );

  @override
  String iconAsset(LogoColorType type) {
    switch (type) {
      case LogoColorType.white:
        return "assets/spotify/Spotify_Icon_RGB_White.png";
      case LogoColorType.black:
        return "assets/spotify/Spotify_Icon_RGB_Green.png";
      default:
        throw UnimplementedError();
    }
  }

  @override
  String iconFullAsset(LogoColorType type) {
    switch (type) {
      case LogoColorType.white:
        return "assets/spotify/Spotify_Logo_RGB_White.png";
      case LogoColorType.black:
        return "assets/spotify/Spotify_Logo_RGB_Green.png";
      default:
        throw UnimplementedError();
    }
  }

  @override
  String get playerName => "Spotify";

  @override
  String get packageName => "com.spotify.music";

  @override
  bool isMediaPlayerNotification(NotificationEvent event) {
    return event.actions?.any(
          (element) => (element.title == "Play") || (element.title == "Pause"),
        ) ??
        false;
  }
}

//! JioSaavn
class SpotifyDataExtractor extends PlayerStateDataExtractor {
  const SpotifyDataExtractor();

  @override
  String albumName(NotificationEvent event) {
    return event.raw?["subText"] as String? ?? "";
  }

  @override
  String singerName(NotificationEvent event) {
    return event.text!;
  }

  @override
  String songName(NotificationEvent event) {
    return event.title!;
  }

  @override
  ActivityState state(NotificationEvent event) {
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == "Play" || element.title == "Pause",
      );
      switch (action.title) {
        case "Play":
          return ActivityState.paused;
        case "Pause":
          return ActivityState.playing;
      }
      return ActivityState.paused;
    } catch (e, s) {
      logExceptRelease(
        "Cannot find Play/Pause action: $e",
        error: e,
        stackTrace: s,
      );
      return ActivityState.paused;
    }
  }

  @override
  Uint8List albumCoverArt(NotificationEvent event) {
    return event.largeIcon!;
  }

  @override
  int timeStamp(NotificationEvent event) {
    return event.timestamp!;
  }
}

class SpotifyPlayerActions extends PlayerActions {
  const SpotifyPlayerActions();

  @override
  Future<void> pause(NotificationEvent event) async {
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == "Pause",
      );
      await action.tap();
    } catch (e, s) {
      logExceptRelease(
        "Cannot find Pause action: $e",
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> play(NotificationEvent event) async {
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == "Play",
      );
      await action.tap();
    } catch (e, s) {
      logExceptRelease(
        "Cannot find Play action: $e",
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> previous(NotificationEvent event) async {
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == "Previous track",
      );
      await action.tap();
    } catch (e, s) {
      logExceptRelease(
        "Cannot find Previous action: $e",
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> next(NotificationEvent event) async {
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == "Next track",
      );
      await action.tap();
    } catch (e, s) {
      logExceptRelease(
        "Cannot find Next action: $e",
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void>? skipToStart(NotificationEvent event) {
    return previous(event);
  }
}
