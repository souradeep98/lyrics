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
      //appBar: const _SettingsAppBar(),
      appBar: AppCustomAppBar(
        title: Text("Settings".tr()),
      ),
      body: ListView(
        children: [
          SettingListTile(
            title: "App Settings".tr(),
            page: const Scaffold(),
          ),
          SettingListTile(
            title: "Music Activity Detection".tr(),
            page: const NotificationAccessPermissionRequestPage(),
          ),
          SettingListTile(
            title: "App Language and Lyrics Translation".tr(),
            page: const Scaffold(),
          ),
          SettingListTile(
            title: "Notification Settings".tr(),
            page: const Scaffold(),
          ),
          SettingListTile(
            title: "Theme".tr(),
            page: const Scaffold(),
          ),
          SettingListTile(
            title: "About".tr(),
            page: const UpdatePage(),
          ),
        ],
      ),
    );
  }
}

class SettingListTile extends StatelessWidget {
  final String title;
  final Widget page;

  const SettingListTile({
    super.key,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        await Navigator.of(context).push<void>(
          PageTransitions<void>.sharedAxis(
            pageBuilder: (context, animation, secondaryAnimation) => page,
          ),
        );
      },
    );
  }
}

/*class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ignore: unused_element
  const _SettingsAppBar({super.key});

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigatorState = Navigator.of(context);
    return Material(
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
}*/
