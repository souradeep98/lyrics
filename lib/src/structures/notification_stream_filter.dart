part of structures;

class NotificationStreamFilter with FireOnCalm, LogHelperMixin {
  final int millisecondsDelay;

  final List<DetectedPlayerData> _stream = [];

  final StreamController<DetectedPlayerData> _streamController =
      StreamController<DetectedPlayerData>();

  Stream<DetectedPlayerData> get stream => _streamController.stream;

  void onData(DetectedPlayerData playerEvent) {
    //log("Adding $playerStateData");
    _stream.add(playerEvent);

    notCalm();
    //log("OnData(), stream length: ${_stream.length}");
  }

  Future<void> _process() async {
    if (_stream.isEmpty) {
      return;
    }

    _release(
      releaseStartIndex: 0,
      releaseLength: _stream.length,
      resultElementIndex: _stream.length - 1,
    );
  }

  void _release({
    required int releaseStartIndex,
    required int releaseLength,
    required int resultElementIndex,
  }) {
    try {
      //log("Setting value of index $resultElementIndex");
      //log("Releasing from $releaseStartIndex of length: $releaseLength\n");
      _streamController.add(_stream[resultElementIndex]);
      _stream.removeRange(releaseStartIndex, releaseStartIndex + releaseLength);
      //log("After release: $_stream");
    } catch (e) {
      logER("Release failed: $e\n", error: e);
    }
  }

  void dispose() {
    _streamController.close();
  }

  NotificationStreamFilter({required this.millisecondsDelay}) {
    initializeFireOnCalm(
      calmDownTime: Duration(milliseconds: millisecondsDelay),
      callbackOnCalm: _process,
    );
  }
}
