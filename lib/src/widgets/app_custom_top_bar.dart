part of widgets;

class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget title;
  final bool putBackButtonIfApplicable;
  final bool centerTitle;
  final List<Widget>? actions;
  final TextStyle? titleTextStyle;

  @override
  Size get preferredSize => Size.fromHeight(height);

  const AppCustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.putBackButtonIfApplicable = true,
    this.height = 40,
    this.actions,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigatorState = Navigator.of(context);
    final bool putBackButton =
        putBackButtonIfApplicable && navigatorState.canPop();

    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final Widget titleWidget = DefaultTextStyle(
      style: titleTextStyle ??
          theme.appBarTheme.titleTextStyle ??
          theme.textTheme.headlineMedium!,
      child: MediaQuery(
        data: mediaQueryData.copyWith(textScaleFactor: 0.6),
        child: title,
      ),
    );
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: centerTitle
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (putBackButton)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                  if (actions != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                    ),
                  Align(
                    child: titleWidget,
                  ),
                ],
              )
            : Center(
                child: Row(
                  children: [
                    if (putBackButton) const BackButton(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: titleWidget,
                      ),
                    ),
                    if (actions != null)
                      ...actions!,
                  ],
                ),
              ),
      ),
    );
  }
}
