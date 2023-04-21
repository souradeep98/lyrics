part of utils;

class LocalJsonLocalizationDelegate
    extends LocalizationsDelegate<Translations> with LogHelperMixin {
  final String translationPath;
  final Iterable<Locale> supportedLocales;
  final Locale fallbackLocale;
  final FutureOr<void> Function(Translations? translations)? postLoadCallback;

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
    logER("Loading translations for $locale");
    _locale = locale;
    String filePath = join(translationPath, "$_locale.json");
    if (Platform.isWindows) {
      filePath = filePath.replaceAll("\\", "/");
    }
    final String jsonString = await rootBundle.loadString(filePath);
    final Map<String, dynamic> tranlations =
        jsonDecode(jsonString) as Map<String, dynamic>;
    _translations = Translations(translations: tranlations);
    logER(
      "Loaded translations for $_locale, translations: ${_translations?.translations.length}",
    );
    postLoadCallback?.call(_translations);
    return _translations!;
  }

  @override
  bool shouldReload(covariant LocalJsonLocalizationDelegate old) {
    final bool result = (_locale.toString() != "null") &&
        ((old._locale != _locale) || (old.translationPath != translationPath));
    logER("LocalJsonLocalizationDelegate.shouldReload: $result");
    return result;
  }

  String getTranslation(String source) {
    final String? translation = _translations?.translations[source] as String?;
    final bool translationIsNull = translation == null;
    if (translationIsNull) {
      logER(
        "Can't find translation for $_locale: $source",
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
  static FutureOr<void> Function(Translations? translations)? _postLoadCallback;

  static FutureOr<void> Function(Translations? translations)?
      // ignore: unnecessary_getters_setters
      get postLoadCallback => _postLoadCallback;

  static set postLoadCallback(
    FutureOr<void> Function(
      Translations? translations,
    )?
        postLoadCallback,
  ) {
    _postLoadCallback = postLoadCallback;
  }

  static final LocalJsonLocalizationDelegate delegate =
      LocalJsonLocalizationDelegate(
    translationPath: appTranslationPath,
    supportedLocales: AppLocales.appLocales.values,
    fallbackLocale: AppLocales.defaultLocale,
    postLoadCallback: (x) async {
      await postLoadCallback?.call(x);
    },
  );

  static String translate(String source) {
    return delegate.getTranslation(source);
  }
}

extension LocalizationTranslationStringExtension on String {
  String translate() {
    return LocalJsonLocalizations.translate(this);
  }
}

class LocalJsonLocalizationWidget extends InheritedWidget {
  final Locale locale;

  const LocalJsonLocalizationWidget({
    super.key,
    required this.locale,
    required super.child,
  });

  static LocalJsonLocalizationWidget? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocalJsonLocalizationWidget>();
  }

  @override
  bool updateShouldNotify(LocalJsonLocalizationWidget oldWidget) {
    return true;
  }
}
