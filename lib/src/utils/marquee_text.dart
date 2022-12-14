part of utils;

class MarqueeText extends StatelessWidget {
  final Text text;
  final Duration? forwardDuration;
  final Duration? backDuration;
  final int? forwardDurationPerCharacter;
  final bool autoRepeat;
  final bool ignoring;

  const MarqueeText({
    super.key,
    required this.text,
    this.forwardDurationPerCharacter,
    this.forwardDuration,
    this.backDuration,
    this.autoRepeat = true,
    this.ignoring = true,
  });

  @override
  Widget build(BuildContext context) {
    final int length = text.data?.length ?? 0;
    return IgnorePointer(
      ignoring: ignoring,
      child: Marquee(
        animationDuration: forwardDuration ??
            Duration(
              milliseconds: length * (forwardDurationPerCharacter ?? 200),
            ),
        backDuration: backDuration ??
            const Duration(
              milliseconds: 30,
            ),
        child: text,
        autoRepeat: autoRepeat,
      ),
    );
  }
}
