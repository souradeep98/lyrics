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
  late final TextEditingController _languageCode;

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
    _languageCode = TextEditingController(
      text: widget.initialData?.languageCode,
    );
  }

  @override
  void dispose() {
    _songTitle.dispose();
    _singerName.dispose();
    _albumName.dispose();
    _languageCode.dispose();
    super.dispose();
  }

  String? _validator(String? value) =>
      value?.isEmpty ?? true ? "This Field Must Not Be Empty".tr() : null;

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final String languageCode = _languageCode.text.trim();
    final SongBase songBase = SongBase(
      songName: _songTitle.text.trim(),
      singerName: _singerName.text.trim(),
      albumName: _albumName.text.trim(),
      languageCode: languageCode.isEmpty ? null : languageCode.toLowerCase(),
    );
    widget.onSave(songBase);
  }

  @override
  Widget build(BuildContext context) {
    return AllWhite(
      child: AppThemedTextField(
        child: Scaffold(
          body: Stack(
            children: [
              AlbumArtView(
                resolvedAlbumArt: widget.initialData,
                initialImage: widget.initialAlbumArt,
                dimValue: 0.65,
                loadClip: true,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _TextField(
                              controller: _songTitle,
                              validator: _validator,
                              labelText: "Song Title".tr(),
                            ),
                            _TextField(
                              controller: _singerName,
                              validator: _validator,
                              labelText: "Artist Name".tr(),
                            ),
                            _TextField(
                              controller: _albumName,
                              labelText: "Album Name".tr(),
                            ),
                            _TextField(
                              controller: _languageCode,
                              //validator: _validator,
                              labelText: "Language Code".tr(),
                            ),
                            ElevatedButton(
                              onPressed: _onSave,
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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String labelText;

  const _TextField({
    // ignore: unused_element
    super.key,
    required this.controller,
    this.validator,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
        ),
      ),
    );
  }
}
