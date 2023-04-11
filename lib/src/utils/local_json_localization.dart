part of utils;

class LocalJsonLocalizationDelegate
    extends LocalizationsDelegate<Translations> {
  final String translationPath;
  final Iterable<Locale> supportedLocales;
  final Locale fallbackLocale;
  final VoidCallback? postLoadCallback;

  LocalJsonLocalizationDelegate({
    required this.translationPath,
    required this.supportedLocales,
    required this.fallbackLocale,
    this.postLoadCallback,
  });

  Locale? _locale;
  Translations? _translations;

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<Translations> load(Locale locale) async {
    logExceptRelease("Loading translations for $locale");
    _locale = locale;
    String filePath = join(translationPath, "$_locale.json");
    if (Platform.isWindows) {
      filePath = filePath.replaceAll("\\", "/");
    }
    final String jsonString = await rootBundle.loadString(filePath);
    final Map<String, dynamic> tranlations =
        jsonDecode(jsonString) as Map<String, dynamic>;
    _translations = Translations(translations: tranlations);
    logExceptRelease(
      "Loaded translations for $_locale, translations: ${_translations?.translations.length}",
    );
    postLoadCallback?.call();
    return _translations!;
  }

  @override
  bool shouldReload(covariant LocalJsonLocalizationDelegate old) {
    final bool result = (_locale.toString() != "null") &&
        ((old._locale != _locale) || (old.translationPath != translationPath));
    logExceptRelease("LocalJsonLocalizationDelegate.shouldReload: $result");
    return result;
  }

  String getTranslation(String source) {
    final String? translation = _translations?.translations[source] as String?;
    final bool translationIsNull = translation == null;
    if (translationIsNull) {
      logExceptRelease(
        "Can't find translation for $_locale: $source ",
        error: "Can't find translation",
      );
    }
    final String result = translationIsNull ? source : translation;
    return result;
  }
}

class Translations {
  final Map<String, dynamic> translations;

  const Translations({
    required this.translations,
  });
}

abstract class LocalJsonLocalizations {
  /*static final LocalJsonLocalizationDelegate delegate =
      LocalJsonLocalizationDelegate(
    translationPath: appTranslationPath,
    supportedLocales: AppLocales.appLocales.values,
    fallbackLocale: AppLocales.defaultLocale,
  );*/

  static LocalJsonLocalizationDelegate? _cachedDelegate;

  static LocalJsonLocalizationDelegate getDelegate({
    VoidCallback? postLoadCallback,
  }) {
    return _cachedDelegate ??= LocalJsonLocalizationDelegate(
      translationPath: appTranslationPath,
      supportedLocales: AppLocales.appLocales.values,
      fallbackLocale: AppLocales.defaultLocale,
      postLoadCallback: postLoadCallback,
    );
  }

  static String translate(String source) {
    return _cachedDelegate!.getTranslation(source);
  }
}

extension LocalizationTranslationStringExtension on String {
  String translate() {
    return LocalJsonLocalizations.translate(this);
  }
}
