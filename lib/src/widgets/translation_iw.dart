part of '../widgets.dart';

class TranslationsListener extends StatefulWidget {
  final Widget child;

  const TranslationsListener({
    super.key,
    required this.child,
  });

  @override
  State<TranslationsListener> createState() => _TranslationsListenerState();
}

class _TranslationsListenerState extends State<TranslationsListener>
    with LogHelperMixin {
  @override
  void initState() {
    super.initState();
    LocalJsonLocalizations.addListener(_listener);
  }

  @override
  void dispose() {
    LocalJsonLocalizations.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (mounted) {
      setState(
        () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Translations? translations = LocalJsonLocalizations.translations;
    logER(translations);
    return TranslationsForLocale(
      translations: translations ?? const Translations.empty(),
      child: widget.child,
    );
  }
}

class TranslationsForLocale extends InheritedWidget {
  final Translations translations;
  LogHelper get logHelper => const LogHelper();

  const TranslationsForLocale({
    super.key,
    required super.child,
    required this.translations,
  });

  /*static TranslationsForLocale _of(BuildContext context) {
    final TranslationsForLocale? result = _maybeOf(context);
    if (result == null) {
      throw "No TranslationsForLocale ancestor widget found";
    }

    return result;
  }*/

  static TranslationsForLocale? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TranslationsForLocale>();
  }

  static Translations translationsOf(BuildContext context) {
    final Translations? result = translationsMaybeOf(context);

    if (result == null) {
      throw "No TranslationsForLocale ancestor widget found";
    }

    return result;
  }

  static Translations? translationsMaybeOf(BuildContext context) {
    return _maybeOf(context)?.translations;
  }

  @override
  bool updateShouldNotify(TranslationsForLocale oldWidget) {
    /*logHelper.logER(
      "Old Translations:",
    );

    printJson(
      oldWidget.translations.translations,
      printer: logHelper.logER,
    );

    logHelper.logER(
      "New Translations:",
    );

    printJson(
      translations.translations,
      printer: logHelper.logER,
    );*/

    final bool result = !mapEquals<String, String>(
      oldWidget.translations.translations,
      translations.translations,
    );

    /*logHelper.logER(
      "updateShouldNotify: $result",
    );*/

    return result;
  }
}
