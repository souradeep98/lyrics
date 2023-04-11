part of constants;

abstract class AppLocales {
  static final Map<LocaleInformation, Locale> appLocales = {
    const LocaleInformation(language: "English", country: "US"):
        const Locale('en', 'US'),
    const LocaleInformation(language: "Deutsch", country: "Deutschland"):
        const Locale('de', 'DE'),
  };

  static const Locale defaultLocale = Locale('en', 'US');
}

class LocaleInformation {
  final String language;
  final String country;

  const LocaleInformation({
    required this.language,
    required this.country,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocaleInformation &&
        other.language == language &&
        other.country == country;
  }

  @override
  int get hashCode => language.hashCode ^ country.hashCode;

  @override
  String toString() =>
      'LocaleInformation(language: $language, country: $country)';
}
