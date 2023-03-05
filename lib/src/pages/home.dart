part of pages;

/*enum AppNavigationBarDestinations {
  lyrics,
  settings,
  //x,
}*/

class Home extends StatefulWidget {
  final Animation<double>? animation;

  const Home({
    super.key,
    this.animation,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*late final AppBottomBarController<AppNavigationBarDestinations>
      _appBottomBarController;*/

  @override
  void initState() {
    super.initState();
    /*_appBottomBarController =
        AppBottomBarController<AppNavigationBarDestinations>(
      value: AppNavigationBarDestinations.lyrics,
    );*/
    //NotificationListenerHelper.stopListening();
  }

  @override
  void dispose() {
    //_appBottomBarController.dispose();
    super.dispose();
  }

  static Future<void> _openSettings() async {
    await GKeys.navigatorKey.currentState?.push<void>(
      PageTransitions<void>.sharedAxis(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Settings(),
        transitionType: SharedAxisTransitionType.vertical,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String x = Platform.localeName;
    logExceptRelease("Locale: $x");
    //final ThemeData themeData = Theme.of(context);

    const Widget child = Scaffold(
      //appBar: _HomeAppBar(),
      appBar: AppCustomAppBar(
        title: Text("Lyrics"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: Icon(Icons.settings),
            splashRadius: 20,
            iconSize: 20,
          ),
        ],
      ),
      body: LyricsCatalogView(),
      /*body: SafeArea(
        child: AppBottomNavigationControlledView<AppNavigationBarDestinations>(
          controller: _appBottomBarController,
          viewBuilder: {
            AppNavigationBarDestinations.lyrics: (context) =>
                const LyricsCatalogView(),
            AppNavigationBarDestinations.settings: (context) =>
                const Settings(),
            //AppNavigationBarDestinations.x: (context) => empty,
          },
        ),
      ),*/
      //extendBody: true,
      bottomNavigationBar: CurrentlyPlaying(),
      /*bottomNavigationBar: AppBottomNavigationBar<AppNavigationBarDestinations>(
        itemBuilder: {
          AppNavigationBarDestinations.lyrics: (context, isSelected) {
            return const Icon(Icons.music_note);
          },
          AppNavigationBarDestinations.settings: (context, isSelected) {
            return const Icon(Icons.settings);
          },
          /*AppNavigationBarDestinations.x: (context, isSelected) =>
              const Icon(Icons.music_note),*/
        },
        controller: _appBottomBarController,
        onTop: const CurrentlyPlaying(),
        labels: {
          AppNavigationBarDestinations.lyrics: "Lyrics".tr(),
          AppNavigationBarDestinations.settings: "Settings".tr(),
        },
        selectedColors: {
          AppNavigationBarDestinations.lyrics: themeData.primaryColor,
          AppNavigationBarDestinations.settings: themeData.primaryColorDark,
        },
      ),*/
    );
    return widget.animation == null
        ? child
        : FadeTransition(
            opacity: widget.animation!,
            child: child,
          );
  }
}

/*
class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ignore: unused_element
  const _HomeAppBar({super.key});

  static const double height = 40;

  /*Future<void> _showBottomSheet(BuildContext context) async {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    await showModalBottomSheet(
      context: context,
      builder: (context) => const _BottomSheet(),
      enableDrag: true,
      elevation: 10,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.35,
        maxWidth: mediaQuery.size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }*/

  Future<void> _openSettings(BuildContext context) async {
    await Navigator.of(context).push<void>(
      PageTransitions<void>.sharedAxis(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Settings(),
        transitionType: SharedAxisTransitionType.vertical,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Lyrics",
                    textScaleFactor: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _openSettings(context);
                },
                icon: const Icon(Icons.settings),
                splashRadius: height / 2,
                iconSize: height / 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(height);
}*/

/*
class _BottomSheet extends StatelessWidget {
  // ignore: unused_element
  const _BottomSheet({super.key});

  static void _goToSettings() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "More Options",
              textScaleFactor: 1.1,
            ),
          ),
          ListTile(
            dense: true,
            title: Text("Settings"),
            onTap: _goToSettings,
          ),
        ],
      ),
      /*body: PhysicalShape(
        elevation: 10,
        clipper: const ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "More Options",
                textScaleFactor: 1.1,
              ),
            ),
            ListTile(
              dense: true,
              title: Text("Settings"),
              onTap: _goToSettings,
            ),
          ],
        ),
      ),*/
    );
  }
}
*/
