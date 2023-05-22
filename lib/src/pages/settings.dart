part of '../pages.dart';

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
        title: Text("Settings".translate(context)),
      ),
      body: ListView(
        children: const [
          SettingListTile(
            title: "Personalization",
            page: Scaffold(),
          ),
          SettingListTile(
            title: "Music Activity Detection",
            page: NotificationAccessPermissionRequestPage(
              title: "Music Activity Detection",
            ),
          ),
          SettingListTile(
            title: "App Language and Lyrics Translation",
            page: AppLanguageAndTranslationSettings(
              title: "App Language and Lyrics Translation",
            ),
          ),
          SettingListTile(
            title: "Notification Settings",
            page: Scaffold(),
          ),
          SettingListTile(
            title: "Theme",
            page: ThemeSettings(
              title: "Theme",
            ),
          ),
          SettingListTile(
            title: "About",
            page: UpdatePage(
              title: "About",
            ),
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
      title: Text(title.translate(context)),
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
                  "Settings".translation(),
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
