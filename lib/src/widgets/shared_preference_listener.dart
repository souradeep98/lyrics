part of widgets;

typedef SharedPreferenceListenerBuilder<T, X> = Widget Function(
  BuildContext context,
  T value,
  X? object,
);

class SharedPreferenceListener<T, X> extends StatefulWidget {
  final String? sharedPreferenceKey;
  final SharedPreferenceListenerBuilder<T, X> builder;
  final X? object;
  final T valueIfNull;
  final T? Function(String)? valueGetter;

  const SharedPreferenceListener({
    super.key,
    this.sharedPreferenceKey,
    required this.builder,
    this.object,
    required this.valueIfNull,
    this.valueGetter,
  }) : assert(
          valueGetter == null || sharedPreferenceKey != null,
          "sharedPreferenceKey must not be null, when valueGetter is not null",
        );

  @override
  State<SharedPreferenceListener<T, X>> createState() =>
      _SharedPreferenceListenerState<T, X>();
}

class _SharedPreferenceListenerState<T, X>
    extends State<SharedPreferenceListener<T, X>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(SharedPreferenceListener<T, X> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dispose();
    _initialize();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _initialize() {
    if (widget.sharedPreferenceKey != null) {
      logExceptRelease("Getting value for: ${widget.sharedPreferenceKey}");
      if (widget.valueGetter != null) {
        final T? value = widget.valueGetter!.call(widget.sharedPreferenceKey!);
        if (value is Locale) {
          _value = (value.toString() != "null") ? value : widget.valueIfNull;
        } else {
          _value = value ?? widget.valueIfNull;
        }
      } else {
        final T? value = SharedPreferencesHelper.getValue<T>(
          widget.sharedPreferenceKey!,
        );
        if (value is Locale) {
          _value = (value.toString() != "null") ? value : widget.valueIfNull;
        } else {
          _value = value ?? widget.valueIfNull;
        }
      }
      logExceptRelease("Got value for ${widget.sharedPreferenceKey}: $_value");
    }

    SharedPreferencesHelper.addListener(
      _listener,
      key: widget.sharedPreferenceKey,
    );
  }

  void _dispose() {
    SharedPreferencesHelper.removeListener(
      _listener,
      key: widget.sharedPreferenceKey,
    );
  }

  void _listener(dynamic value) {
    logExceptRelease(
      "Running SharedPreferenceListener._listener() for: ${widget.sharedPreferenceKey}",
    );
    if (widget.valueGetter == null) {
      if (value is Locale) {
        _value = (value.toString() != "null") ? (value as T) : widget.valueIfNull;
      } else {
        _value = (value as T?) ?? widget.valueIfNull;
      }
    } else if (widget.sharedPreferenceKey != null) {
      final T? value = widget.valueGetter!.call(widget.sharedPreferenceKey!);
      if (value is Locale) {
        _value = (value.toString() != "null") ? value : widget.valueIfNull;
      } else {
        _value = value ?? widget.valueIfNull;
      }
    }

    setState(
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _value,
      widget.object,
    );
  }
}
