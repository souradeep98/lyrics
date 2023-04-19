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

    _clipStream = StreamDataObservable<File?>(
      stream: DatabaseHelper.getClipStreamFor(song),
    ).put<StreamDataObservable<File?>>(
      tag: "Clip - ${song.songKey()}",
    );
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
              loadingIndicator: empty,
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
                  loadingIndicator: empty,
                ),
              ),
            //! Dim overlay
            if (widget.autoDim ||
                widget.overlayColor != null ||
                widget.dimValue != null)
              DimOverlay(
                dimValue: widget.dimValue!,
                dimColor: widget.overlayColor ?? Colors.black,
              ),
          ],
        );
      },
    );
  }
}
