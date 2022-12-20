part of recognized_players;

class SpotifyPlayer extends RecognisedPlayer {
  static const SpotifyNotificationLables _lables = SpotifyNotificationLables();
  const SpotifyPlayer()
      : super(
          stateExtractor: const SpotifyDataExtractor(lables: _lables),
          actions: const SpotifyPlayerActions(lables: _lables),
          lables: _lables,
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
    final String playString = lables.play;
    final String pauseString = lables.pause;
    return event.actions?.any(
          (element) => (element.title == playString) || (element.title == pauseString),
        ) ??
        false;
  }
}

class SpotifyDataExtractor extends PlayerStateDataExtractor {
  const SpotifyDataExtractor({required super.lables});

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
    final String playString = lables.play;
    final String pauseString = lables.pause;
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == playString || element.title == pauseString,
      );
      if (action.title == playString) {
        return ActivityState.paused;
      } else {
        return ActivityState.playing;
      }
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
  const SpotifyPlayerActions({required super.lables});

  @override
  Future<void> pause(NotificationEvent event) async {
    final String pauseString = lables.pause;
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == pauseString,
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
    final String playString = lables.play;
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == playString,
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
    final String previousString = lables.previous;
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == previousString,
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
    final String nextString = lables.next;
    try {
      final Action action = event.actions!.firstWhere(
        (element) => element.title == nextString,
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

class SpotifyNotificationLables extends NotificationLables {
  const SpotifyNotificationLables();

  @override
  String get pause {
    return "Pause";
  }

  @override
  String get play {
    return "Play";
  }

  @override
  String get previous {
    final String localeString = Platform.localeName;
    final List<String> strings = localeString.split("_");

    switch (strings.first) {
      case "de":
        return "Vorheriger Titel";
      case "en":
      default:
        return "Previous track";
    }
  }

  @override
  String get next {
    final String localeString = Platform.localeName;
    final List<String> strings = localeString.split("_");

    switch (strings.first) {
      case "de":
        return "Nächster Titel";
      case "en":
      default:
        return "Next track";
    }
  }
}
