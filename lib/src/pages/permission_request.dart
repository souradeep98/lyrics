part of pages;

Future<void> showPermissionRequest(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PermissionRequest(),
  );
}

class PermissionRequest extends StatefulWidget {
  const PermissionRequest({super.key});

  @override
  State<PermissionRequest> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
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
                const Padding(
                  padding:
                      EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
                  child: Text(
                    "Notification permission is needed to find out and control music your device is playing.",
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await NotificationsListener.openPermissionSettings();
                    bool inside = false;
                    late final Timer x;
                    x = Timer.periodic(const Duration(seconds: 1), (_) async {
                      if (inside) {
                        return;
                      }
                      inside = true;
                      if ((await NotificationsListener.hasPermission) ??
                          false) {
                        await SharedPreferencesHelper
                            .setNotificationPermissionDenied(
                          false,
                        );
                        x.cancel();
                        if (!mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      }
                      inside = false;
                    });
                  },
                  child: const Text("Give Permission"),
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
                child: const Text(
                  "Continue without it",
                  style: TextStyle(
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
