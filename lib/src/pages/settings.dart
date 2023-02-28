part of pages;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _SettingsAppBar(),
      body: ListView(
        children: [
          ListTile(
            title: Text("Music Activity Detection".tr()),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ignore: unused_element
  const _SettingsAppBar({super.key});

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigatorState = Navigator.of(context);
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (navigatorState.canPop())
              const Align(
                alignment: Alignment.centerLeft,
                child: BackButton(),
              ),
            Align(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Settings".tr(),
                  textScaleFactor: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(height);
}
