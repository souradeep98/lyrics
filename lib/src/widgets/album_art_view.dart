part of widgets;

class AlbumArtView extends StatefulWidget {
  final Uint8List? initialImage;
  final SongBase? resolvedSongBase;
  final Color? overlayColor;
  final bool autoDim;
  final double? dimValue;

  const AlbumArtView({
    super.key,
    this.initialImage,
    required this.resolvedSongBase,
    this.overlayColor,
    this.autoDim = false,
    this.dimValue,
  });

  @override
  State<AlbumArtView> createState() => _AlbumArtViewState();
}

class _AlbumArtViewState extends State<AlbumArtView>
    with SingleTickerProviderStateMixin {
  static const Duration _revealDuration = Duration(milliseconds: 500);
  static const Duration _hideDuration = Duration(milliseconds: 150);
  late Stream<Uint8List?> _stream;
  UniqueKey _initialWidgetKey = UniqueKey();
  UniqueKey _dbImageWidgetKey = UniqueKey();
  late Uint8List _initialImage;
  Uint8List? _dbImage;

  @override
  void initState() {
    super.initState();
    _initialImage = widget.initialImage ?? kTransparentImage;
    //_calculateLuminance();
    _stream = DatabaseHelper.getAlbumArtStreamFor(
      widget.resolvedSongBase ?? const SongBase.doesNotExist(),
    );
  }

  @override
  void didUpdateWidget(AlbumArtView oldWidget) {
    if (oldWidget.resolvedSongBase != widget.resolvedSongBase) {
      _stream = DatabaseHelper.getAlbumArtStreamFor(
        widget.resolvedSongBase ?? const SongBase.doesNotExist(),
      );
    }
    if (!listEquals(
      oldWidget.initialImage,
      widget.initialImage,
    )) {
      //logExceptRelease("Should refresh initialImage");
      _initialWidgetKey = UniqueKey();
      _initialImage = widget.initialImage ?? kTransparentImage;
    }
    super.didUpdateWidget(oldWidget);
  }

  static Widget defaultLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  Future<void> _calculateLuminance({Uint8List? data}) async {
    final imagelib.Image? image =
        imagelib.decodeImage(data ?? _dbImage ?? _initialImage);
    if (image == null) {
      return;
    }
    final Uint8List bytes = image.getBytes();

    double colorSum = 0;
    for (var x = 0; x < bytes.length; x += 4) {
      final int r = bytes[x];
      final int g = bytes[x + 1];
      final int b = bytes[x + 2];
      final double avg = (r + g + b) / 3;
      colorSum += avg;
    }

    final double brightness = colorSum / (image.width * image.height);
    logExceptRelease("brightness: $brightness");
  }

  @override
  Widget build(BuildContext context) {
    //logExceptRelease("Building album art");
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: _revealDuration,
          reverseDuration: _hideDuration,
          layoutBuilder: defaultLayoutBuilder,
          child: Image.memory(
            _initialImage,
            key: _initialWidgetKey,
            fit: BoxFit.cover,
          ),
        ),
        StreamBuilder<Uint8List?>(
          stream: _stream,
          builder: (context, snapshot) {
            final Uint8List dbImage = snapshot.data ?? kTransparentImage;
            if (!listEquals(_dbImage, dbImage)) {
              _dbImageWidgetKey = UniqueKey();
              //_calculateLuminance(data: dbImage);
            }
            _dbImage = dbImage;
            return AnimatedSwitcher(
              duration: _revealDuration,
              reverseDuration: _hideDuration,
              layoutBuilder: defaultLayoutBuilder,
              child: Image.memory(
                _dbImage!,
                key: _dbImageWidgetKey,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        if (widget.autoDim ||
            widget.overlayColor != null ||
            widget.dimValue != null)
          _Dim(
            dimValue: widget.dimValue!,
            dimColor: widget.overlayColor ?? Colors.black,
          ),
        /*if (widget.overlayColor != null)
          ColoredBox(
            color: widget.overlayColor!,
            child: const SizedBox.expand(),
          ),*/
      ],
    );
  }
}

class _Dim extends StatefulWidget {
  final double dimValue;
  final Duration animateDuration;
  final Curve animationCurve;
  final Color? dimColor;

  const _Dim({
    // ignore: unused_element
    super.key,
    required this.dimValue,
    // ignore: unused_element
    this.animateDuration = const Duration(milliseconds: 350),
    // ignore: unused_element
    this.animationCurve = Curves.linear,
    // ignore: unused_element
    this.dimColor,
  });

  @override
  State<_Dim> createState() => __DimState();
}

class __DimState extends State<_Dim> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, value: widget.dimValue);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Dim oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(
      widget.dimValue,
      duration: widget.animateDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.dimColor ?? Colors.black;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ColoredBox(
          color: color.withOpacity(_animationController.value),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

/*class _AlbumArtViewState extends State<AlbumArtView>
    with TickerProviderStateMixin {
  late final ValueNotifier<Uint8List> _initialImage;
  late final ValueNotifier<Uint8List?> _dbImageData;
  ValueListenable<LazyBox<String>>? _dbListenable;
  late final AnimationController _dbImageAnimationController;
  late final AnimationController _initialImageAnimationController;
  //late UniqueKey _initialImageKey;

  static const Duration _revealDuration = Duration(milliseconds: 500);
  static const Duration _hideDuration = Duration(milliseconds: 150);

  SongBase get _songBase => widget.songBase;
  PlayerStateData? get _playerStateData => widget.playerStateData;

  @override
  void initState() {
    //logExceptRelease("AlbumArt View initState: ${_playerStateData?.songName}");
    super.initState();
    _initialImage = ValueNotifier<Uint8List>(
      _playerStateData?.albumCoverArt ?? kTransparentImage,
    );
    //_initialImageKey = UniqueKey();
    _dbImageAnimationController = AnimationController(
      vsync: this,
    );
    _initialImageAnimationController = AnimationController(
      vsync: this,
    );
    _dbImageData = ValueNotifier<Uint8List?>(null);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (mounted) {
          _setInitialImageVisibilityState(true);
        }
      },
    );
    _load(loadInitial: false);
  }

  @override
  void dispose() {
    //logExceptRelease("AlbumArt View dispose: ${_playerStateData?.songName}");
    _dbImageAnimationController.dispose();
    _initialImageAnimationController.dispose();
    _dbImageData.dispose();
    _initialImage.dispose();
    _dbListenable?.removeListener(_dbListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(AlbumArtView oldWidget) {
    /*logExceptRelease(
      "AlbumArt View didUpdateWidget: ${_playerStateData?.songName}",
    );*/
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songBase != widget.songBase) {
      _dbListenable!.removeListener(_dbListener);
      _setDBImage(null);
      _load();
    }
  }

  Future<void> _load({bool loadInitial = true}) async {
    if (loadInitial) {
      //_initialImageKey = UniqueKey();
      //logExceptRelease(_playerStateData?.albumCoverArt);
      _setInitialImage(_playerStateData?.albumCoverArt ?? kTransparentImage);
    }

    _setDBImage(await _loadDBImageData());
    _dbListenable = DatabaseHelper.getAlbumArtListenable(_songBase);
    _dbListenable!.addListener(_dbListener);
  }

  Future<void> _dbListener() async {
    _setDBImage(await _loadDBImageData());
  }

  Future<Uint8List?> _loadDBImageData() {
    return DatabaseHelper.getAlbumArtFor(_songBase);
  }

  Future<void> _setDBImage(Uint8List? data) async {
    if (!mounted) {
      return;
    }
    if (data == null) {
      await _setDBImageVisibilityState(false);
      _dbImageData.value = null;
    } else {
      if (_dbImageData.value != null) {
        await _setDBImageVisibilityState(false);
      }
      _dbImageData.value = data;
      await _setDBImageVisibilityState(true);
    }
  }

  Future<void> _setDBImageVisibilityState(
    bool state, {
    Duration? duration,
  }) async {
    if (!mounted) {
      return;
    }
    if (state) {
      await _dbImageAnimationController.animateTo(
        1,
        duration: duration ?? _revealDuration,
      );
    } else {
      await _dbImageAnimationController.animateTo(
        0,
        duration: duration ?? _hideDuration,
      );
    }
  }

  Future<void> _setInitialImage(Uint8List data) async {
    if (!mounted) {
      return;
    }
    await _setInitialImageVisibilityState(false);
    _initialImage.value = data;
    await _setInitialImageVisibilityState(true);
  }

  Future<void> _setInitialImageVisibilityState(
    bool state, {
    Duration? duration,
  }) async {
    if (!mounted) {
      return;
    }
    if (state) {
      await _initialImageAnimationController.animateTo(
        1,
        duration: duration ?? _revealDuration,
      );
    } else {
      await _initialImageAnimationController.animateTo(
        0,
        duration: duration ?? _hideDuration,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder<Uint8List>(
          valueListenable: _initialImage,
          builder: (context, data, _) {
            return Image.memory(
              data,
              //key: _initialImageKey,
              fit: BoxFit.cover,
              opacity: CurvedAnimation(
                parent: _initialImageAnimationController,
                curve: Curves.easeIn,
              ),
            );
          },
        ),
        ValueListenableBuilder<Uint8List?>(
          valueListenable: _dbImageData,
          builder: (context, data, _) {
            return Image.memory(
              data ?? kTransparentImage,
              fit: BoxFit.cover,
              opacity: CurvedAnimation(
                parent: _dbImageAnimationController,
                curve: Curves.easeIn,
              ),
            );
          },
        )
      ],
    );
  }
}

class AnimatedImageBuilder extends StatefulWidget {
  final Widget Function(Uint8List data) builder;
  final Duration revealDuration;
  final Duration hideDuration;
  const AnimatedImageBuilder({
    super.key,
    required this.builder,
    this.revealDuration = const Duration(milliseconds: 500),
    this.hideDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedImageBuilder> createState() => _AnimatedImageBuilderState();
}

class _AnimatedImageBuilderState extends State<AnimatedImageBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setImageVisibilityState(bool state) async {
    if (!mounted) {
      return;
    }
    if (state) {
      await _animationController.animateTo(
        1,
        duration: widget.revealDuration,
      );
    } else {
      await _animationController.animateTo(
        0,
        duration: widget.hideDuration,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List>(builder: (context) {
      return widget.builder(
        _animationController,
      );
    });
  }
}*/

/*
class AlbumArtView extends StatefulWidget {
  final PlayerStateData? playerStateData;
  final SongBase songBase;

  const AlbumArtView({
    super.key,
    this.playerStateData,
    required this.songBase,
  });

  @override
  State<AlbumArtView> createState() => _AlbumArtViewState();
}

class _AlbumArtViewState extends State<AlbumArtView> {
  late SingleGenerateObservable<Uint8List?> _imageData;
  late ValueListenable<LazyBox<String>> _listenable;
  late String _tag;

  SongBase get _songBase => widget.songBase;
  PlayerStateData? get _playerStateData => widget.playerStateData;

  @override
  void initState() {
    super.initState();

    _tag = "Album_Art_${widget.songBase.toBase().toRawJson()}";

    _imageData = SingleGenerateObservable<Uint8List>(
      dataGenerator: (_) async =>
          _playerStateData?.albumCoverArt ?? kTransparentImage,
      allowModification: true,
      postInit: (_) {
        _loadImageData();
      },
    );
    _imageData.put(tag: _tag);
    _listenable = DatabaseHelper.getAlbumArtListenable(_songBase);
    _listenable.addListener(_loadImageData);
  }

  @override
  void didUpdateWidget(AlbumArtView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songBase != widget.songBase) {
      logExceptRelease("Should load new image");
      _tag = "Album_Art_${widget.songBase.toBase().toRawJson()}";
      _listenable.removeListener(_loadImageData);
      _listenable = DatabaseHelper.getAlbumArtListenable(_songBase);
      _listenable.addListener(_loadImageData);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _loadImageData();
      });
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_loadImageData);
    super.dispose();
  }

  Future<void> _loadImageData() async {
    logExceptRelease("Reloading Image Data for: $_songBase");
    final Uint8List? result = await DatabaseHelper.getAlbumArtFor(_songBase);
    _imageData.data = result;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DataGenerateObserver<SingleGenerateObservable<Uint8List?>>(
      observable: _imageData,
      builder: (x) {
        final Uint8List? dbImageData = x.data;
        return FadeInImage(
          key: ValueKey<SongBase>(_songBase),
          placeholder: MemoryImage(
            _playerStateData?.albumCoverArt ?? kTransparentImage,
          ),
          image: MemoryImage(
            dbImageData ?? _playerStateData?.albumCoverArt ?? kTransparentImage,
          ),
          fit: BoxFit.cover,
          placeholderFit: BoxFit.cover,
        );
      },
      shouldShowLoading: (_) => false,
      dataIsEmpty: (_) => false,
    );
  }
}
*/
