part of recognized_players;

class JioSaavnPlayer extends RecognisedPlayer {
  static const  JioSaavnNotificationLables _lables = JioSaavnNotificationLables();
  const JioSaavnPlayer()
      : super(
          stateExtractor: const JioSaavnDataExtractor(lables: _lables),
          actions: const JioSaavnPlayerActions(lables: _lables),
          lables: _lables,
        );

  @override
  String iconAsset(LogoColorType type) =>
      "assets/jiosaavn/JioSaavn Icon Transparent Crop.png";

  @override
  String iconFullAsset(LogoColorType type) {
    switch (type) {
      case LogoColorType.white:
        return "assets/jiosaavn/JioSaavn Logo White Transparent Crop.png";
      case LogoColorType.black:
        return "assets/jiosaavn/JioSaavn Logo Black Transparent Crop.png";
      default:
        throw UnimplementedError();
    }
  }

  @override
  String get playerName => "JioSaavn";

  @override
  String get packageName => "com.jio.media.jiobeats";

  @override
  bool isMediaPlayerNotification(NotificationEvent event) {
    final String playString = lables.play;
    final String pauseString = lables.pause;
    return event.actions?.any(
      (element) => (element.title == playString) || (element.title == pauseString),
    ) ?? false;
  }
}

class JioSaavnDataExtractor extends PlayerStateDataExtractor {
  const JioSaavnDataExtractor({required super.lables});

  @override
  String albumName(NotificationEvent event) {
    final List<String> splits = event.text!.split(" - ");
    return splits.last;
  }

  @override
  String singerName(NotificationEvent event) {
    final List<String> splits = event.text!.split(" - ");
    return splits.first;
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
        (element) =>
            element.title == playString || element.title == pauseString,
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

class JioSaavnPlayerActions extends PlayerActions {
  const JioSaavnPlayerActions({required super.lables});

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

class JioSaavnNotificationLables extends NotificationLables {
  const JioSaavnNotificationLables();

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
    return "Previous";
  }

  @override
  String get next {
    return "Next";
  }
}
