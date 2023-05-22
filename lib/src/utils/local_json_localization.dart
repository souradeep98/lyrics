part of '../utils.dart';

class LocalJsonLocalizationDelegate extends LogHelper
    implements LocalizationsDelegate<Translations> {
  final String translationPath;
  final Iterable<Locale> supportedLocales;
  final Locale fallbackLocale;
  final Future<void> Function(Translations? translations)? postLoadCallback;

  const LocalJsonLocalizationDelegate({
    required this.translationPath,
    required this.supportedLocales,
    required this.fallbackLocale,
    this.postLoadCallback,
  });

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<Translations> load(Locale locale) async {
    logER("Loading translations for $locale");
    //_locale = locale;
    String filePath = join(translationPath, "$locale.json");

    if (Platform.isWindows) {
      filePath = filePath.replaceAll("\\", "/");
    }
    final String jsonString = await rootBundle.loadString(filePath);

    final Map<String, String> translationsMap =
        (jsonDecode(jsonString) as Map<String, dynamic>).cast<String, String>();

    final Translations translations =
        Translations(translations: translationsMap);
    logER(
      "Loaded translations for $locale, translations: ${translationsMap.length}",
    );

    postLoadCallback?.call(translations);

    return translations;
  }

  @override
  bool shouldReload(covariant LocalJsonLocalizationDelegate old) {
    final bool result = (old.translationPath != translationPath);
    logER("LocalJsonLocalizationDelegate.shouldReload: $result");
    return result;
  }

  /*String getTranslation(String source) {
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
  }*/

  @override
  Type get type => Translations;
}

class Translations {
  final Map<String, String> translations;

  const Translations({
    required this.translations,
  });

  const Translations.empty() : translations = const {};

  String? operator [](String string) {
    return translations[string];
  }

  String translate(String string) {
    return translations[string] ?? string;
  }
}

abstract class LocalJsonLocalizations {
  static Translations? _translations;

  static Translations? get translations => _translations;

  static final LocalJsonLocalizationDelegate delegate =
      LocalJsonLocalizationDelegate(
    translationPath: appTranslationPath,
    supportedLocales: AppLocales.appLocales.values,
    fallbackLocale: AppLocales.defaultLocale,
    postLoadCallback: (x) async {
      _translations = x;
      if (!_translationLoadCompleter.isCompleted) {
        _translationLoadCompleter.complete();
      }
      notifyListeners();
    },
  );

  static final Completer<void> _translationLoadCompleter = Completer<void>();

  static Future<void> get translationInitializing =>
      _translationLoadCompleter.future;

  static String translate(String source) {
    final String? translation = _translations?[source];
    if (translation == null) {
      logER('Translation not found for: "$source"');
      return source;
    }
    return translation;
  }

  static final Set<VoidCallback> _listeners = {};

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void notifyListeners() {
    for (final VoidCallback listener in _listeners) {
      listener();
    }
  }

  static void logER(
    Object? message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logExceptRelease(
      message,
      time: time ?? DateTime.now(),
      sequenceNumber: sequenceNumber,
      level: level,
      name: "LocalJsonLocalizations",
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

extension LocalizationTranslationStringExtension on String {
  String translate([BuildContext? context]) {
    if (context == null) {
      return LocalJsonLocalizations.translate(this);
    }

    final String? translation =
        TranslationsForLocale.translationsOf(context)[this];
    if (translation == null) {
      logExceptRelease(
        'Translation not found for: "$this"',
        name: "LocalJsonLocalizations",
      );
      return this;
    }
    return translation;
  }
}
