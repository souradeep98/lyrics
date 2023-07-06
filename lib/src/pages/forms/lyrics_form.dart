part of '../../pages.dart';

typedef LyricsOnSave = FutureOr<void> Function(List<String>? newLines);

Future<void> showLyricsForm({
  required List<LyricsLine>? lyrics,
  required LyricsOnSave onSave,
  required Uint8List? initialAlbumArt,
  SongBase? song,
}) async {
  await navigateToPagePush<void>(
    LyricsForm(
      onSave: onSave,
      lyrics: lyrics,
      initialAlbumArt: initialAlbumArt,
      song: song,
    ),
  );
}

class LyricsForm extends StatefulWidget {
  final List<LyricsLine>? lyrics;
  final LyricsOnSave onSave;
  final Uint8List? initialAlbumArt;
  final SongBase? song;

  const LyricsForm({
    super.key,
    required this.lyrics,
    required this.onSave,
    //required this.albumArt,
    required this.initialAlbumArt,
    this.song,
  });

  @override
  State<LyricsForm> createState() => _LyricsFormState();
}

class _LyricsFormState extends State<LyricsForm> {
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _snackbarController;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: _getStringFromLyrics());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String? _getStringFromLyrics() {
    if (widget.lyrics == null) {
      return null;
    }
    return widget.lyrics!.map<String>((e) => e.line).join("\n").trim();
  }

  Future<bool> _onWillPop() async {
    if (_textEditingController.text.trim().isNotEmpty) {
      final Completer<bool> result = Completer<bool>();
      _snackbarController?.close();
      _snackbarController = showTextSnack(
        "You will lose all your progress. Are you sure?".translate(context),
        action: SnackBarAction(
          label: "Yes".translate(context),
          textColor: Colors.white,
          onPressed: () {
            result.complete(true);
          },
        ),
      );
      _snackbarController?.closed.then((_) {
        _snackbarController = null;
      });
      return result.future;
    }
    return true;
  }

  Future<void> _onClose() async {
    if (await _onWillPop()) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
  }

  Future<void> _onDone() async {
    if (_textEditingController.text.trim().isEmpty) {
      await widget.onSave(null);
      return;
    }
    final List<String> lines =
        _textEditingController.text.split("\n").map((e) => e.trim()).toList();
    if (lines.isEmpty) {
      await widget.onSave(null);
    } else {
      await widget.onSave(
        [
          ...lines,
          if (lines.last.isNotEmpty) "",
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AllWhite(
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              AlbumArtView(
                songbase: widget.song,
                initialImage: widget.initialAlbumArt,
                resolvedAlbumArt: widget.song,
                loadClip: true,
              ),
              GestureDetector(
                onTap: _focusNode.requestFocus,
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.8),
                  child: SizedBox.fromSize(
                    size: size,
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Field
                      Expanded(
                        child: Center(
                          child: TextField(
                            focusNode: _focusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            controller: _textEditingController,
                            //expands: true,
                            minLines: 1,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText:
                                  "${'Enter Song lyrics here'.translate(context)}...",
                              border: InputBorder.none,
                              hintStyle: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: _onClose,
                            tooltip: "Cancel".translate(context),
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            icon: const Icon(
                              Icons.done_rounded,
                            ),
                            onPressed: _onDone,
                            tooltip: "Continue".translate(context),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
