part of pages;

enum AppNavigationBarDestinations {
  lyrics,
  settings,
  //x,
}

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
  late final AppBottomBarController<AppNavigationBarDestinations>
      _appBottomBarController;

  @override
  void initState() {
    super.initState();
    _appBottomBarController =
        AppBottomBarController<AppNavigationBarDestinations>(
      value: AppNavigationBarDestinations.lyrics,
    );
    //NotificationListenerHelper.stopListening();
  }

  @override
  void dispose() {
    _appBottomBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String x = Platform.localeName;
    logExceptRelease("Locale: $x");
    final ThemeData themeData = Theme.of(context);

    final Widget child = Scaffold(
      body: SafeArea(
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
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNavigationBar<AppNavigationBarDestinations>(
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
      ),
    );
    return widget.animation == null
        ? child
        : FadeTransition(
            opacity: widget.animation!,
            child: child,
          );
  }
}
