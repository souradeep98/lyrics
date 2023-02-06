part of widgets;

class ClipPlayer extends StatefulWidget {
  final File? file;
  final bool play;
  final BoxFit fit;

  const ClipPlayer({
    // ignore: unused_element
    super.key,
    required this.file,
    this.play = true,
    this.fit = BoxFit.contain,
  });

  @override
  State<ClipPlayer> createState() => _ClipPlayerState();
}

class _ClipPlayerState extends State<ClipPlayer> {
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initialize(playPause: true);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ClipPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file?.path != oldWidget.file?.path) {
      _videoPlayerController?.dispose();
      _initialize(playPause: true);
    }
    /*if (widget.play != oldWidget.play) {
      if (widget.play) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.pause();
      }
    }*/
  }

  Future<void> _initialize({bool playPause = false}) async {
    if (widget.file != null) {
      _videoPlayerController = VideoPlayerController.file(
        widget.file!,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
          mixWithOthers: true,
        ),
      );
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      if (playPause) {
        if (widget.play) {
          await _videoPlayerController!.play();
        } else {
          await _videoPlayerController!.pause();
        }
      }
      setState(() {});
    } else {
      await _videoPlayerController?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.file == null || !_videoPlayerController!.value.isInitialized
        ? empty
        : SizedBox.fromSize(
            size: _videoPlayerController!.value.size,
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox.fromSize(
                size: _videoPlayerController!.value.size,
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: AnimatedShowHide(
                    isShown: _videoPlayerController!.value.isInitialized,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
              ),
            ),
          );
  }
}
