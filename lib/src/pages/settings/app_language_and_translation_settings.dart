part of pages;

class AppLanguageAndTranslationSettings extends StatefulWidget {
  const AppLanguageAndTranslationSettings({super.key});

  @override
  State<AppLanguageAndTranslationSettings> createState() =>
      _AppLanguageAndTranslationSettingsState();
}

class _AppLanguageAndTranslationSettingsState
    extends State<AppLanguageAndTranslationSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: const [
            _AppLanguageSettings(),
            _LyricsTranslationSettings(),
          ],
        ),
      ),
    );
  }
}

class _AppLanguageSettings extends StatefulWidget {
  const _AppLanguageSettings({
    // ignore: unused_element
    super.key,
  });

  @override
  State<_AppLanguageSettings> createState() => _AppLanguageSettingsState();
}

class _AppLanguageSettingsState extends State<_AppLanguageSettings> {
  late final UniqueKey _key;
  late Map<Locale, LocaleInformation> _reversedAppLocales;

  @override
  void initState() {
    super.initState();
    _key = UniqueKey();
    _reversedAppLocales = AppLocales.appLocales.switchSides();
  }

  Future<void> _onTap() async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return _AppLanguageSelector(
            tag: _key,
          );
        },
        opaque: false,
        barrierDismissible: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Locale? currentLocale = SharedPreferencesHelper.getDeviceLocale();
    late final String currentLanguage;
    if (currentLocale.toString() == "null") {
      currentLanguage = "Device Default".translate();
    } else {
      currentLanguage = _reversedAppLocales[currentLocale]?.language ??
          currentLocale!.languageCode;
    }

    return Hero(
      tag: _key,
      child: Card(
        child: ListTile(
          title: Text("Language".translate()),
          trailing: Text(
            currentLanguage,
            style: const TextStyle(fontWeight: FontWeight.w600,),
          ),
          onTap: _onTap,
        ),
      ),
    );
  }
}

class _AppLanguageSelector extends StatefulWidget {
  final UniqueKey tag;

  const _AppLanguageSelector({
    // ignore: unused_element
    super.key,
    required this.tag,
  });

  @override
  State<_AppLanguageSelector> createState() => _AppLanguageSelectorState();
}

class _AppLanguageSelectorState extends State<_AppLanguageSelector> {
  final List<MapEntry<LocaleInformation, Locale>?> _locales = [
    null,
    ...AppLocales.appLocales.entries,
  ];

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final Locale? currentLocale = SharedPreferencesHelper.getDeviceLocale();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQueryData.size.height * 0.7,
          maxWidth: mediaQueryData.size.width * 0.7,
        ),
        child: Hero(
          tag: widget.tag,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final Locale? locale = _locales[index]?.value;
                return _AppLanguageSelectionListTile(
                  localeInformation: _locales[index]?.key,
                  locale: locale,
                  isCurrent: currentLocale.toString() == locale.toString(),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                indent: 16,
                endIndent: 16,
              ),
              itemCount: _locales.length,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLanguageSelectionListTile extends StatelessWidget {
  final Locale? locale;
  final LocaleInformation? localeInformation;
  final bool isCurrent;

  const _AppLanguageSelectionListTile({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    required this.localeInformation,
    // ignore: unused_element
    required this.locale,
    required this.isCurrent,
  });

  Future<void> _onTap() async {
    await SharedPreferencesHelper.setDeviceLocale(locale);

    GKeys.navigatorKey.currentState?.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        localeInformation?.language ?? "Device Default".translate(),
        locale: locale,
      ),
      onTap: _onTap,
      trailing: isCurrent ? const Icon(Icons.done) : null,
    );
  }
}

class _LyricsTranslationSettings extends StatefulWidget {
  const _LyricsTranslationSettings({
    // ignore: unused_element
    super.key,
  });

  @override
  State<_LyricsTranslationSettings> createState() =>
      __LyricsTranslationSettingsState();
}

class __LyricsTranslationSettingsState
    extends State<_LyricsTranslationSettings> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
