part of '../../pages.dart';

class ThemeSettings extends StatefulWidget {
  final String title;

  const ThemeSettings({super.key, required this.title,});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCustomAppBar(
        title: Text(
          widget.title.translate(context),
        ),
      ),
      body: SharedPreferenceListener<AppThemePresets, Widget>(
        sharedPreferenceKey: SharedPreferencesHelper.keys.appThemePreset,
        valueGetter: (_) {
          return SharedPreferencesHelper.getAppThemePreset();
        },
        valueIfNull: AppThemePresets.device,
        builder: (context, value, _) {
          return ListView(
            children: [
              ...AppThemePresets.values.map<Widget>(
                (e) => _ThemeSelectionListTile(
                  preset: e,
                  groupValue: value,
                  onSelected: (x) {
                    SharedPreferencesHelper.setAppThemePreset(x);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeSelectionListTile extends StatelessWidget {
  final AppThemePresets preset;
  final AppThemePresets groupValue;
  final void Function(AppThemePresets value) onSelected;

  const _ThemeSelectionListTile({
    // ignore: unused_element
    super.key,
    required this.preset,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemePresets>(
      value: preset,
      groupValue: groupValue,
      title: Text(preset.prettyName),
      onChanged: (x) {
        if (x == null) {
          return;
        }
        onSelected(x);
      },
    );
  }
}
