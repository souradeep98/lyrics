part of pages;

class AlbumArtAndClipForm extends StatefulWidget {
  final Uint8List? initialAlbumArt;
  final SongBase song;
  final VoidCallback onContinue;

  const AlbumArtAndClipForm({
    super.key,
    required this.initialAlbumArt,
    required this.song,
    required this.onContinue,
  });

  @override
  State<AlbumArtAndClipForm> createState() => _AlbumArtAndClipFormState();
}

class _AlbumArtAndClipFormState extends State<AlbumArtAndClipForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /*AlbumArtView(
            initialImage: widget.initialAlbumArt,
            resolvedAlbumArt: widget.song,
            dimValue: 0.7,
          ),*/
          Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: NoOverscrollGlow(
                      child: ListView(
                        children: [
                          _AlbumArtCard(
                            song: widget.song,
                          ),
                          _ClipCard(
                            song: widget.song,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  ElevatedButton(
                    onPressed: () {
                      widget.onContinue();
                    },
                    child: Text("Continue".tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumArtCard extends StatefulWidget {
  final SongBase song;

  const _AlbumArtCard({
    // ignore: unused_element
    super.key,
    required this.song,
  });

  @override
  State<_AlbumArtCard> createState() => __AlbumArtCardState();
}

class __AlbumArtCardState extends State<_AlbumArtCard> {
  late StreamDataObservable<Uint8List?> _observable;

  @override
  void initState() {
    super.initState();
    _observable = StreamDataObservable<Uint8List?>(
      stream: DatabaseHelper.getAlbumArtStreamFor(widget.song),
      initialDataGenerator: () => DatabaseHelper.getAlbumArtFor(widget.song),
    ).put<StreamDataObservable<Uint8List?>>(
      tag: "AlbumArt - ${widget.song.songKey()}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          logExceptRelease(constraints.biggest);
          return Padding(
            padding: const EdgeInsets.all(30),
            child: PhysicalShape(
              clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: StreamDataObserver<StreamDataObservable<Uint8List?>>(
                observable: _observable,
                shouldShowLoading: (_) => false,
                builder: (controller) {
                  final bool dataIsPresent = controller.data != null;
                  logExceptRelease("Image is present: $dataIsPresent");
                  return Stack(
                    children: [
                      AnimatedShowHide(
                        isShown: dataIsPresent,
                        child: Image.memory(
                          controller.data ?? kTransparentImage,
                          fit: BoxFit.cover,
                          height: constraints.biggest.height,
                          width: constraints.biggest.width,
                        ),
                      ),
                      _AddEditLayer(
                        //isAdd: false,
                        isAdd: dataIsPresent,
                        title: const Text("Album Art"),
                        onAddOrEdit: (x) {
                          addAlbumArt(widget.song);
                        },
                      ),
                    ],
                  );
                },
                dataIsEmpty: (_) => false,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClipCard extends StatefulWidget {
  final SongBase song;

  const _ClipCard({
    // ignore: unused_element
    super.key,
    required this.song,
  });

  @override
  State<_ClipCard> createState() => __ClipCardState();
}

class __ClipCardState extends State<_ClipCard> {
  late StreamDataObservable<File?> _observable;

  @override
  void initState() {
    super.initState();
    _observable = StreamDataObservable<File?>(
      stream: DatabaseHelper.getClipStreamFor(widget.song)
          .cast<FileMedia?>()
          .map((event) => event?.data),
      initialDataGenerator: () => (DatabaseHelper.getClipFor(widget.song))
          .then<File?>((value) => value?.data as File),
    ).put<StreamDataObservable<File?>>(tag: "Clip - ${widget.song.songKey()}");
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: PhysicalShape(
          clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: StreamDataObserver<StreamDataObservable<File?>>(
            observable: _observable,
            shouldShowLoading: (_) => false,
            builder: (controller) {
              return Stack(
                children: [
                  ClipPlayer(
                    file: controller.data,
                    fit: BoxFit.cover,
                  ),
                  _AddEditLayer(
                    //isAdd: true,
                    isAdd: controller.data == null,
                    title: const Text("Clip"),
                    onAddOrEdit: (x) {
                      addClip(widget.song);
                    },
                  ),
                ],
              );
            },
            dataIsEmpty: (_) => false,
          ),
        ),
      ),
    );
  }
}

class _AddEditLayer extends StatefulWidget {
  final Widget title;
  final bool isAdd;
  final FutureOr<void> Function(bool isAdd) onAddOrEdit;

  const _AddEditLayer({
    // ignore: unused_element
    super.key,
    required this.isAdd,
    required this.title,
    required this.onAddOrEdit,
  });

  @override
  State<_AddEditLayer> createState() => __AddEditLayerState();
}

class __AddEditLayerState extends State<_AddEditLayer>
    with SingleTickerProviderStateMixin {
  static const Curve _animationCurve = Curves.easeInOut;
  static const Duration _animationDuration = Duration(milliseconds: 650);
  late final AnimationController _animationController;
  final AlignmentTween _alignmentTween = AlignmentTween(
    begin: Alignment.bottomRight,
    end: Alignment.center,
  );
  final Tween<double> _scaleTween = Tween<double>(begin: 0.8, end: 2);
  late final Animation<Alignment> _alignmentAnimation;
  late final Animation<double> _scaleAnimation;
  late final ValueNotifier<bool> _isInProgress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: widget.isAdd.toNumeric.toDouble(),
    );
    _alignmentAnimation = _alignmentTween.animate(_animationController);
    _scaleAnimation = _scaleTween.animate(_animationController);
    _isInProgress = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isInProgress.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AddEditLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(
      widget.isAdd.toNumeric.toDouble(),
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  Widget get _iconWidget {
    final bool isInProgress = _isInProgress.value;
    if (isInProgress) {
      return const SpinIt(
        child: Icon(
          EvilIcons.spinner_3,
          //size: 20,
        ),
      );
    } else {
      return widget.isAdd
          ? const Icon(
              Icons.add_circle_outline_rounded,
              key: ValueKey<String>("isAdd"),
            )
          : const Icon(
              Icons.edit,
              key: ValueKey<String>("isEdit"),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AllWhite(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.2, -1),
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.18),
              Colors.black.withOpacity(0.09),
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.22),
            ],
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () async {
              _isInProgress.value = true;
              await widget.onAddOrEdit(widget.isAdd);
              _isInProgress.value = false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                /*Align(
                      alignment: const Alignment(0, -0.9),
                      child: widget.title,
                    ),*/
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: widget.title,
                  ),
                ),
                // Icon
                AlignTransition(
                  alignment: _alignmentAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isInProgress,
                        builder: (context, _, __) {
                          return AnimatedSwitcher(
                            duration: _animationDuration,
                            child: _iconWidget,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
