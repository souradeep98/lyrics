part of pages;

class Home extends StatefulWidget {
  final Animation<double>? animation;

  const Home({super.key, this.animation,});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    NotificationListenerHelper.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Column(
          children: const [
            Expanded(
              child: LyricsCatalogView(),
            ),
            CurrentlyPlaying(),
          ],
        );
    return Scaffold(
      body: widget.animation == null ? child :  FadeTransition(
        opacity: widget.animation!,
        child: child,
      ),
      extendBody: true,
    );
  }
}
