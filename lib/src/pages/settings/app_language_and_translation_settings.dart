part of '../../pages.dart';

class AppLanguageAndTranslationSettings extends StatefulWidget {
  final String title;

  const AppLanguageAndTranslationSettings({
    super.key,
    required this.title,
  });

  @override
  State<AppLanguageAndTranslationSettings> createState() =>
      _AppLanguageAndTranslationSettingsState();
}

class _AppLanguageAndTranslationSettingsState
    extends State<AppLanguageAndTranslationSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCustomAppBar(
        title: Text(
          widget.title.translate(),
        ),
      ),
      body: ListView(
        children: const [
          _AppLanguageSettings(),
          _LyricsTranslationSettings(),
        ],
      ),
    );
  }
}

class _AppLanguageSettings extends StatefulWidget {
  // ignore: unused_element
  const _AppLanguageSettings({super.key});

  @override
  State<_AppLanguageSettings> createState() => __AppLanguageSettingsState();
}

class __AppLanguageSettingsState extends State<_AppLanguageSettings> {
  late Map<Locale, LocaleInformation> _reversedAppLocales;
  final List<MapEntry<LocaleInformation, Locale>?> _locales = [
    null,
    ...AppLocales.appLocales.entries,
  ];

  @override
  void initState() {
    super.initState();
    _reversedAppLocales = AppLocales.appLocales.switchSides();
  }

  @override
  Widget build(BuildContext context) {
    return _PopupItem(
      closed: Text("Language".translate()),
      closedTrailing: SharedPreferenceListener<Locale?, TextStyle>(
        valueIfNull: null,
        sharedPreferenceKey: SharedPreferencesHelper.keys.appLocale,
        valueGetter: (key) => SharedPreferencesHelper.getDeviceLocale(),
        builder: (context, currentLocale, object) {
          late final String currentLanguage;
          if (currentLocale.toString() == "null") {
            currentLanguage = "Device Default".translate();
          } else {
            currentLanguage = _reversedAppLocales[currentLocale]?.language ??
                currentLocale!.languageCode;
          }
          return Text(
            currentLanguage,
            style: object,
          );
        },
        object: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      popup: _AppLanguageSelector(
        locales: _locales,
      ),
    );
  }
}

class _AppLanguageSelector extends StatelessWidget {
  final List<MapEntry<LocaleInformation, Locale>?> locales;

  const _AppLanguageSelector({
    // ignore: unused_element
    super.key,
    required this.locales,
  });

  @override
  Widget build(BuildContext context) {
    return SharedPreferenceListener<Locale?,
        Widget Function(BuildContext, int)>(
      sharedPreferenceKey: SharedPreferencesHelper.keys.appLocale,
      valueIfNull: null,
      valueGetter: (key) => SharedPreferencesHelper.getDeviceLocale(),
      builder: (context, currentLocale, object) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final Locale? locale = locales[index]?.value;
            return _AppLanguageSelectionListTile(
              localeInformation: locales[index]?.key,
              locale: locale,
              isCurrent: currentLocale.toString() == locale.toString(),
            );
          },
          separatorBuilder: object!,
          itemCount: locales.length,
        );
      },
      object: (context, index) => const Divider(
        indent: 16,
        endIndent: 16,
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
    final String? language = localeInformation?.language;
    final String title = [
      language ?? "Device Default".translate(),
      if (language == null) "(${Platform.localeName})",
    ].join(" ");

    return ListTile(
      title: Text(
        title,
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
    return _PopupItem(
      closed: Text("Lyrics Translation Language".translate()),
      closedTrailing: SharedPreferenceListener<String?, String>(
        sharedPreferenceKey:
            SharedPreferencesHelper.keys.lyricsTranslationLanguage,
        valueIfNull: null,
        valueGetter: (key) =>
            SharedPreferencesHelper.getLyricsTranslationLanguage(),
        builder: (context, value, object) {
          return Text(
            value ?? object!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          );
        },
        object: "Off".translate(),
      ),
      popup: const _LyricsTranslatorLanguageSelector(),
    );
  }
}

class _LyricsTranslatorLanguageSelector extends StatefulWidget {
  // ignore: unused_element
  const _LyricsTranslatorLanguageSelector({super.key});

  @override
  State<_LyricsTranslatorLanguageSelector> createState() =>
      _LyricsTranslatorLanguageSelectorState();
}

class _LyricsTranslatorLanguageSelectorState
    extends State<_LyricsTranslatorLanguageSelector> {
  late final TextEditingController _textEditingController;
  late final List<String?> _languageList;
  late final String _platformLanguage;
  late final String? _appLanguage;
  late final String? _currentTranslationLanguage;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _languageList = _getTranslationLanguageList();
  }

  List<String?> _getTranslationLanguageList() {
    final Set<String?> languages = <String?>{
      null,
      _currentTranslationLanguage =
          SharedPreferencesHelper.getLyricsTranslationLanguage(),
      _appLanguage = SharedPreferencesHelper.getDeviceLocaleName(),
      _platformLanguage = Platform.localeName,
      ...AppLocales.appLocales.values.map<String>((e) => e.toString()),
    };

    return languages.toList();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _onLanguageSaved() async {
    /*if (language == null) {
      await SharedPreferencesHelper.setLyricsTranslationLanguage(null);
      return;
    }*/

    final String language = _textEditingController.text;

    if (language.isEmpty) {
      return;
    }

    await SharedPreferencesHelper.setLyricsTranslationLanguage(language);
    GKeys.navigatorKey.currentState?.pop();
  }

  String? _getLanguageDescription(String? language) {
    if (language == null) {
      return null;
    } else if (language == _appLanguage) {
      return "App Language".translate();
    } else if (language == _platformLanguage) {
      return "Device Default".translate();
    }
    return null;
  }

  final Tween<Offset> _slideAnimationTween = Tween<Offset>(
    begin: const Offset(0.1, 0),
    //begin: Offset.zero,
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            left: 16,
            right: 16.0,
            bottom: 8.0,
          ),
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: "Or enter a language code".translate(),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textEditingController,
                builder: (context, value, child) {
                  return AnimatedShowHide(
                    isShown: value.text.trim().length >= 2,
                    child: child!,
                    showDuration: const Duration(milliseconds: 180),
                    hideDuration: const Duration(milliseconds: 180),
                    transitionBuilder: (context, animation, child) =>
                        FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: _slideAnimationTween.animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                  onPressed: _onLanguageSaved,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final String? language = _languageList[index];
              return _LyricsTranslationLanguageSelectorListTile(
                languageName: language,
                description: _getLanguageDescription(language),
                isCurrent: _currentTranslationLanguage == language,
              );
            },
            separatorBuilder: (context, index) => const Divider(
              indent: 16,
              endIndent: 16,
            ),
            itemCount: _languageList.length,
          ),
        ),
      ],
    );
  }
}

class _LyricsTranslationLanguageSelectorListTile extends StatelessWidget {
  final String? languageName;
  final String? description;
  final bool isCurrent;

  const _LyricsTranslationLanguageSelectorListTile({
    // ignore: unused_element
    super.key,
    required this.languageName,
    // ignore: unused_element
    this.description,
    required this.isCurrent,
  });

  Future<void> _onPressed() async {
    await SharedPreferencesHelper.setLyricsTranslationLanguage(languageName);
    GKeys.navigatorKey.currentState?.pop();
  }

  @override
  Widget build(BuildContext context) {
    final String title = [
      languageName ?? "Off".translate(),
      if (description != null) "($description)",
    ].join(" ");

    return ListTile(
      title: Text(title),
      onTap: _onPressed,
      trailing: isCurrent ? const Icon(Icons.done) : null,
    );
  }
}

// Utility Widgets
class _PopupItem extends StatefulWidget {
  final Widget closed;
  final Widget? closedTrailing;
  final Widget? closedSub;
  final Widget popup;

  const _PopupItem({
    // ignore: unused_element
    super.key,
    required this.closed,
    required this.popup,
    // ignore: unused_element
    this.closedTrailing,
    // ignore: unused_element
    this.closedSub,
  });

  @override
  State<_PopupItem> createState() => _PopupItemState();
}

class _PopupItemState extends State<_PopupItem> {
  late final UniqueKey _key;

  @override
  void initState() {
    super.initState();
    _key = UniqueKey();
  }

  Future<void> _onTap() async {
    await Navigator.of(context).push<void>(
      _PopupPageRoute<void>(
        builder: (context) {
          return _PopupExpanded(
            tag: _key,
            child: widget.popup,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      createRectTween: (begin, end) {
        return _CustomRectTween(begin: begin, end: end);
      },
      tag: _key,
      child: Card(
        child: ListTile(
          title: widget.closed,
          subtitle: widget.closedSub,
          trailing: widget.closedTrailing,
          onTap: _onTap,
        ),
      ),
    );
  }
}

/*class _PopupPageRoute<T> extends PageRoute<T> {
  @override
  final String? barrierLabel;
  final WidgetBuilder builder;

  _PopupPageRoute({
    required this.builder,
    this.barrierLabel,
    super.settings,
  });

  @override
  Color? get barrierColor => Colors.black45;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get barrierDismissible => true;
}*/

class _PopupPageRoute<T> extends PageTransitions<T> {
  _PopupPageRoute({
    required WidgetBuilder builder,
  }) : super.none(
          //shouldTransitionTo: false,
          pageBuilder: (context, _, __) => builder(context),
          shouldTransitionFrom: false,
        );

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => true;
}

class _CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  _CustomRectTween({
    required super.begin,
    required super.end,
  });

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin?.left, end?.left, elasticCurveValue)!,
      lerpDouble(begin?.top, end?.top, elasticCurveValue)!,
      lerpDouble(begin?.right, end?.right, elasticCurveValue)!,
      lerpDouble(begin?.bottom, end?.bottom, elasticCurveValue)!,
    );
  }
}

class _PopupExpanded extends StatelessWidget {
  final UniqueKey tag;
  final Widget child;

  const _PopupExpanded({
    // ignore: unused_element
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQueryData.size.height * 0.7,
          maxWidth: mediaQueryData.size.width * 0.7,
        ),
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) {
            return _CustomRectTween(begin: begin, end: end);
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }
}
