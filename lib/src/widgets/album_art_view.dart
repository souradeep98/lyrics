part of widgets;

class AlbumArtView extends StatefulWidget {
  final Uint8List? initialImage;
  final SongBase? resolvedAlbumArt;
  final Color? overlayColor;
  final bool autoDim;
  final double? dimValue;
  final bool loadClip;

  const AlbumArtView({
    super.key,
    this.initialImage,
    required this.resolvedAlbumArt,
    this.overlayColor,
    this.autoDim = false,
    this.dimValue,
    this.loadClip = false,
  });

  @override
  State<AlbumArtView> createState() => _AlbumArtViewState();
}

class _AlbumArtViewState extends State<AlbumArtView>
    with SingleTickerProviderStateMixin {
  static const Duration _revealDuration = Duration(milliseconds: 500);
  static const Duration _hideDuration = Duration(milliseconds: 150);
  late StreamDataObservable<Uint8List?> _dbImageStream;
  late StreamDataObservable<File?> _clipStream;
  UniqueKey _initialWidgetKey = UniqueKey();
  UniqueKey _dbImageWidgetKey = UniqueKey();
  late Uint8List _initialImage;
  Uint8List? _dbImage;

  @override
  void initState() {
    super.initState();
    _initialImage = widget.initialImage ?? kTransparentImage;
    //_calculateLuminance();

    _initialize();
  }

  @override
  void didUpdateWidget(AlbumArtView oldWidget) {
    if (oldWidget.resolvedAlbumArt != widget.resolvedAlbumArt) {
      _initialize();
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

  void _initialize() {
    final SongBase song =
        widget.resolvedAlbumArt ?? const SongBase.doesNotExist();

    //_dbImageStream = DatabaseHelper.getAlbumArtStreamFor(song);
    _dbImageStream = StreamDataObservable<Uint8List?>(
      stream: DatabaseHelper.getAlbumArtStreamFor(song),
    ).put<StreamDataObservable<Uint8List?>>(
      tag: "AlbumArt - ${song.songKey()}",
    );

    /*_clipStream = DatabaseHelper.getClipStreamFor(song)
        .cast<FileMedia?>()
        .map((event) => event?.data);*/

    _clipStream = StreamDataObservable<File?>(
      stream: DatabaseHelper.getClipStreamFor(song)
          .cast<FileMedia?>()
          .map((event) => event?.data),
    ).put<StreamDataObservable<File?>>(
      tag: "Clip - ${song.songKey()}",
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            //! Initial image
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
            //! Database image
            StreamDataObserver<StreamDataObservable<Uint8List?>>(
              observable: _dbImageStream,
              builder: (controller) {
                final Uint8List dbImage = controller.data ?? kTransparentImage;
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
              dataIsEmpty: (_) => false,
            ),
            //! Clip
            if (widget.loadClip)
              SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: StreamDataObserver<StreamDataObservable<File?>>(
                  observable: _clipStream,
                  builder: (controller) {
                    return ClipPlayer(
                      file: controller.data,
                      fit: BoxFit.cover,
                    );
                  },
                  dataIsEmpty: (_) => false,
                ),
              ),
            //! Dim overlay
            if (widget.autoDim ||
                widget.overlayColor != null ||
                widget.dimValue != null)
              _Dim(
                dimValue: widget.dimValue!,
                dimColor: widget.overlayColor ?? Colors.black,
              ),
          ],
        );
      },
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
