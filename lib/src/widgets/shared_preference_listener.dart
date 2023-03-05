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

  const SharedPreferenceListener({
    super.key,
    this.sharedPreferenceKey,
    required this.builder,
    this.object,
    required this.valueIfNull,
  });

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
      _value = SharedPreferencesHelper.getValue(widget.sharedPreferenceKey!) ??
          widget.valueIfNull;
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
    _value = value as T;
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
