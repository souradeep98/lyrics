part of structures;

class SimplyLyricsTranslator extends LyricsTranslatorBase {
  SimplyTranslator? _translator;

  static const String sharedPreferenceKey = "simply_translator_instance";

  @override
  bool get isInitialized => _translator != null;

  @override
  bool get isNotInitialized => _translator == null;

  @override
  Future<void> initialize() async {
    await _initializeTranslator();
  }

  Future<void> _initializeTranslator({
    bool reset = false,
  }) async {
    _translator = await _getTranslator(reset: reset);
  }

  Future<String?> _getAnWorkingInstance(
    SimplyTranslator translator, {
    bool checkAndReportEvery = false,
    bool saveInSharedPreferences = true,
  }) async {
    final List<String> instances =
        List.castFrom<dynamic, String>(translator.getInstances as List);

    if (checkAndReportEvery) {
      final List<String> working = [];

      final List<String> notWorking = [];

      for (final String instance in instances) {
        final bool result = await translator.isSimplyInstanceWorking(instance);

        if (result) {
          working.add(instance);
        } else {
          notWorking.add(instance);
        }
      }

      printJson(
        {
          "Working": working,
          "Not Working": notWorking,
        },
        printer: logER,
      );

      if (working.isEmpty) {
        return null;
      }

      final String result = working.first;

      if (saveInSharedPreferences) {
        await SharedPreferencesHelper.setValue<String>(
          sharedPreferenceKey,
          result,
        );
      }

      return result;
    }

    for (final String instance in instances) {
      final bool result = await translator.isSimplyInstanceWorking(instance);

      if (result) {
        if (saveInSharedPreferences) {
          await SharedPreferencesHelper.setValue<String>(
            sharedPreferenceKey,
            instance,
          );
        }
        return instance;
      }
    }

    return null;
  }

  Future<SimplyTranslator> _getTranslator({
    bool reset = false,
  }) async {
    final SimplyTranslator translator = SimplyTranslator(EngineType.google);

    late final String? instance;

    if (reset) {
      await SharedPreferencesHelper.removeValue(sharedPreferenceKey);
      instance = await _getAnWorkingInstance(
        translator,
      );
    } else {
      instance = SharedPreferencesHelper.getValue(sharedPreferenceKey) ??
          await _getAnWorkingInstance(
            translator,
          );
    }

    if (instance == null) {
      throw "No instances of translator is working";
    }

    translator.setInstance = instance;

    return translator;
  }

  @override
  Future<List<String>?> getTranslation({
    required List<String> source,
    required String? sourceLanguage,
    required String destinationLanguage,
  }) async {
    if (isInitialized) {
      await initialize();
    }

    try {
      final String toTranslate = source.join("\n");
      
      final Translation translation = await _translator!.translateSimply(
        toTranslate,
        from: sourceLanguage ?? "auto",
        to: destinationLanguage,
        instanceMode: InstanceMode.Same,
      );

      final List<String> result = translation.translations.text.split("\n");

      for (final String x in source) {
        if (x.isEmpty) {
          result.insert(0, "");
        }
      }

      for (final String x in source.reversed) {
        if (x.isEmpty) {
          result.add("");
        }
      }

      return result;
    } catch (e, s) {
      logER(
        "Could not translate, error: $e",
        error: e,
        stackTrace: s,
      );
      await _initializeTranslator(reset: true);
      return getTranslation(
        source: source,
        sourceLanguage: sourceLanguage,
        destinationLanguage: destinationLanguage,
      );
    }
  }

  @override
  Future<void> dispose() async {}
}
