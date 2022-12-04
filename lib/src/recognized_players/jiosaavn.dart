part of recognized_players;

class JioSaavnPlayer extends RecognisedPlayer {
  const JioSaavnPlayer()
      : super(
          stateExtractor: const JioSaavnDataExtractor(),
          actions: const JioSaavnPlayerActions(),
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
    return event.actions?.any(
      (element) => (element.title == "Play") || (element.title == "Pause"),
    ) ?? false;
  }
}

//! JioSaavn
class JioSaavnDataExtractor extends PlayerStateDataExtractor {
  const JioSaavnDataExtractor();

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

class JioSaavnPlayerActions extends PlayerActions {
  const JioSaavnPlayerActions();

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
        (element) => element.title == "Previous",
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
        (element) => element.title == "Next",
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
