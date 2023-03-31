part of pages;

Future<void> showPermissionRequestDialog(
  BuildContext context, {
  String? callerRouteName,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (context) => NotificationAccessPermissionRequestDialog(
      callerRouteName: callerRouteName,
    ),
  );
}

class NotificationAccessPermissionRequestDialog extends StatefulWidget {
  final String? callerRouteName;

  const NotificationAccessPermissionRequestDialog({
    super.key,
    this.callerRouteName,
  });

  @override
  State<NotificationAccessPermissionRequestDialog> createState() =>
      _NotificationAccessPermissionRequestDialogState();
}

class _NotificationAccessPermissionRequestDialogState
    extends State<NotificationAccessPermissionRequestDialog> {
  Timer? __timer;

  Timer? get _timer => __timer;

  @override
  void dispose() {
    __timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 2 / 2.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/lottie/10576-voice-assistant-permissions.json",
                  height: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 30,
                    right: 30,
                    bottom: 10,
                  ),
                  child: Text(
                    "notification_permission_request".tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await NotificationsListener.openPermissionSettings();
                    bool inside = false;
                    __timer = Timer.periodic(
                      const Duration(seconds: 1),
                      (_) async {
                        if (inside) {
                          return;
                        }
                        inside = true;
                        logExceptRelease("checking for permission");
                        if ((await NotificationsListener.hasPermission) ??
                            false) {
                          await SharedPreferencesHelper
                              .setNotificationPermissionDenied(
                            false,
                          );

                          if (!mounted) {
                            logExceptRelease(
                              "Cancelling temporary periodic check",
                            );
                            _timer?.cancel();
                            return;
                          }
                          logExceptRelease("popping permission dialog");
                          if (widget.callerRouteName == null) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).popUntil(
                              (route) =>
                                  route.settings.name == widget.callerRouteName,
                            );
                          }

                          logExceptRelease(
                            "Cancelling temporary periodic check",
                          );
                          _timer?.cancel();
                        }
                        inside = false;
                      },
                    );
                  },
                  child: Text("Give Permission".tr()),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () async {
                  await SharedPreferencesHelper.setNotificationPermissionDenied(
                    true,
                  );

                  if (!mounted) {
                    return;
                  }

                  Navigator.of(context).pop();
                },
                child: Text(
                  "Continue without it".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationAccessPermissionRequestPage extends StatefulWidget {
  const NotificationAccessPermissionRequestPage({super.key});

  @override
  State<NotificationAccessPermissionRequestPage> createState() =>
      _NotificationAccessPermissionRequestPageState();
}

class _NotificationAccessPermissionRequestPageState
    extends State<NotificationAccessPermissionRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SharedPreferenceListener<bool, List<Widget>>(
              valueIfNull: false,
              sharedPreferenceKey:
                  SharedPreferencesHelper.keys.detectMuicActivities,
              builder: (context, value, child) {
                return SwitchListTile(
                  title: child![0],
                  subtitle: child[1],
                  value: value,
                  onChanged: (value) async {
                    await SharedPreferencesHelper.setDetectMusicActivities(
                      value,
                    );
                  },
                );
              },
              object: [
                Text("Detect Music Activities".tr()),
                Text("Detect Music that are playing on this device.".tr()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
