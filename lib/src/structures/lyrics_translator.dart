part of structures;

class LyricsTranslator {
  bool get isInitialized => _instance.isInitialized;
  bool get isNotInitialized => _instance.isNotInitialized;

  Future<void> initialize() => _instance.initialize();

  Future<List<String>?> getTranslation({
    required List<String> source,
    required String? sourceLanguage,
    required String destinationLanguage,
  }) =>
      _instance.getTranslation(
        source: source,
        sourceLanguage: sourceLanguage,
        destinationLanguage: destinationLanguage,
      );

  Future<void> dispose() => _instance.dispose();

  final LyricsTranslator _instance = SimplyLyricsTranslator();
}
