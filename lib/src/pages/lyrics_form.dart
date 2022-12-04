part of pages;

typedef LyricsOnSave = FutureOr<bool?> Function(PlayerStateData, List<String>?);

Future<void> showLyricsForm({
  required List<LyricsLine>? lyrics,
  required LyricsOnSave onSave,
  //required Uint8List albumArt,
  required PlayerStateData playerStateData,
}) async {
  await navigateToPagePush<void>(
    LyricsForm(
      //albumArt: albumArt,
      onSave: onSave,
      lyrics: lyrics,
      playerStateData: playerStateData,
    ),
  );
}

class LyricsForm extends StatefulWidget {
  final List<LyricsLine>? lyrics;
  final LyricsOnSave onSave;
  //final Uint8List albumArt;
  final PlayerStateData playerStateData;

  const LyricsForm({
    super.key,
    required this.lyrics,
    required this.onSave,
    //required this.albumArt,
    required this.playerStateData,
  });

  @override
  State<LyricsForm> createState() => _LyricsFormState();
}

class _LyricsFormState extends State<LyricsForm> {
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;

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

  String _getStringFromLyrics() {
    if (widget.lyrics == null) {
      return "";
    }
    return widget.lyrics!.map<String>((e) => e.line).join("\n").trim();
  }

  void _onClose() {
    if (_textEditingController.text.trim().isNotEmpty) {
      showTextSnack(
        "You will lose all your progress. Are you sure?",
        action: SnackBarAction(
          label: "Yes",
          onPressed: Navigator.of(context).pop,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onDone() async {
    final List<String> lines =
        _textEditingController.text.split("\n").map((e) => e.trim()).toList();
    if (lines.isEmpty) {
      await widget.onSave(widget.playerStateData, null);
    } else {
      await widget.onSave(
        widget.playerStateData,
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
    return AllWhite(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AlbumArtView(
              playerStateData: widget.playerStateData,
              resolvedSongBase: widget.playerStateData.resolvedSong,
            ),
            GestureDetector(
              onTap: _focusNode.requestFocus,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.5),
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
                            fontSize: 22,
                          ),
                          controller: _textEditingController,
                          //expands: true,
                          minLines: 1,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: "Enter Song lyrics here...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
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
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          icon: const Icon(
                            Icons.done_rounded,
                          ),
                          onPressed: _onDone,
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
    );
  }
}
