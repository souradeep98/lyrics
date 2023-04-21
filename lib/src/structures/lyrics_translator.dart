part of structures;

class LyricsTranslator extends LyricsTranslatorBase {
  @override
  bool get isInitialized => _instance.isInitialized;
  @override
  bool get isNotInitialized => _instance.isNotInitialized;

  @override
  FutureOr<void> initialize() => _instance.initialize();

  @override
  FutureOr<List<String>?> getTranslation({
    required List<String> source,
    required String? sourceLanguage,
    required String destinationLanguage,
  }) =>
      _instance.getTranslation(
        source: source,
        sourceLanguage: sourceLanguage,
        destinationLanguage: destinationLanguage,
      );

  @override
  FutureOr<void> dispose() => _instance.dispose();

  final LyricsTranslatorBase _instance = SimplyLyricsTranslator();
}

abstract class LyricsTranslatorBase extends LogHelper{
  const LyricsTranslatorBase();

  bool get isInitialized;
  bool get isNotInitialized;

  FutureOr<void> initialize();

  FutureOr<List<String>?> getTranslation({
    required List<String> source,
    required String? sourceLanguage,
    required String destinationLanguage,
  });

  FutureOr<void> dispose();
}
