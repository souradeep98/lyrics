part of widgets;

class AppThemedTextField extends StatelessWidget {
  final Widget child;

  const AppThemedTextField({
    super.key,
    required this.child,
  });

  InputDecorationTheme _getInputDecorationTheme(BuildContext context) {
    final ThemeData themedata = Theme.of(context);
    final Color color = themedata.textTheme.bodyMedium?.color ?? Colors.white;
    const BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(16.0),
    );

    final TextStyle textStyle = TextStyle(color: color);

    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
        ),
        borderRadius: borderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color.withOpacity(0.3),
        ),
        borderRadius: borderRadius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
        ),
        borderRadius: borderRadius,
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
        borderRadius: borderRadius,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 56, 5, 5),
        ),
        borderRadius: borderRadius,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 250, 7, 7),
        ),
        borderRadius: borderRadius,
      ),
      filled: true,
      fillColor: color.withOpacity(0.1),
      labelStyle: textStyle,
      hintStyle: textStyle,
      helperStyle: textStyle,
      counterStyle: textStyle,
      floatingLabelStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context).copyWith(
      inputDecorationTheme: _getInputDecorationTheme(context),
    );
    return Theme(
      data: themeData,
      child: child,
    );
  }
}
