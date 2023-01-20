part of pages;

typedef SongDetailsOnSave = FutureOr<void> Function(SongBase? song);

Future<void> showSongDetailsForm({
  required SongBase initialData,
  required SongDetailsOnSave onSave,
  Uint8List? initialAlbumArt,
}) async {
  await navigateToPagePush<void>(
    SongDetailsForm(
      initialData: initialData,
      onSave: onSave,
      initialAlbumArt: initialAlbumArt,
    ),
  );
}

class SongDetailsForm extends StatefulWidget {
  final SongBase? initialData;
  final SongDetailsOnSave onSave;
  final Uint8List? initialAlbumArt;

  const SongDetailsForm({
    super.key,
    required this.initialData,
    required this.onSave,
    this.initialAlbumArt,
  });

  @override
  State<SongDetailsForm> createState() => _SongDetailsFormState();
}

class _SongDetailsFormState extends State<SongDetailsForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _songTitle;
  late final TextEditingController _singerName;
  late final TextEditingController _albumName;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    _songTitle = TextEditingController(
      text: widget.initialData?.songName,
    );
    _singerName = TextEditingController(
      text: widget.initialData?.singerName,
    );
    _albumName = TextEditingController(
      text: widget.initialData?.albumName,
    );
  }

  @override
  void dispose() {
    _songTitle.dispose();
    _singerName.dispose();
    _albumName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*const Widget heightSpacer = SizedBox(
      height: 14,
    );*/
    const double bottomPadding = 14;
    return AllWhite(
      child: AppThemedTextField(
        child: Scaffold(
          body: Stack(
            children: [
              AlbumArtView(
                resolvedSongBase: widget.initialData,
                initialImage: widget.initialAlbumArt,
                overlayColor: Colors.black.withOpacity(0.7),
              ),
              Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          delay: const Duration(milliseconds: 70),
                          duration: const Duration(milliseconds: 350),
                          childAnimationBuilder: (child) => SlideAnimation(
                            verticalOffset: 10,
                            child: FadeInAnimation(
                              child: child,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: Text(
                                "Enter Song Details".tr(),
                                textScaleFactor: 2,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: bottomPadding),
                              child: TextFormField(
                                validator: (value) => value?.isEmpty ?? true
                                    ? "This Field Must Not Be Empty".tr()
                                    : null,
                                controller: _songTitle,
                                decoration: InputDecoration(
                                  labelText: "Song Title".tr(),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: bottomPadding),
                              child: TextFormField(
                                validator: (value) => value?.isEmpty ?? true
                                    ? "This Field Must Not Be Empty".tr()
                                    : null,
                                controller: _singerName,
                                decoration: InputDecoration(
                                  labelText: "Artist Name".tr(),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: bottomPadding),
                              child: TextFormField(
                                controller: _albumName,
                                decoration: InputDecoration(
                                  labelText: "Album Name".tr(),
                                ),
                              ),
                            ),
                            //const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                final SongBase songBase = SongBase(
                                  songName: _songTitle.text.trim(),
                                  singerName: _singerName.text.trim(),
                                  albumName: _albumName.text.trim(),
                                );
                                widget.onSave(songBase);
                              },
                              child: Text("Save".tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
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
