part of utils;

class AllWhite extends StatelessWidget {
  final Widget child;
  const AllWhite({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: child,
    );
  }
}
