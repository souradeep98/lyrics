part of widgets;

typedef OnPlayPause = FutureOr<void> Function(ActivityState);

class ControlButtons extends StatelessWidget {
  final ActivityState state;
  final OnPlayPause? onPlayPause;
  final AsyncVoidCallback? onPrevious;
  final AsyncVoidCallback? onNext;
  final double? previousIconSize;
  final double? nextIconSize;
  final double? playPauseIconSize;

  const ControlButtons({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    this.previousIconSize,
    this.nextIconSize,
    this.playPauseIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: previousIconSize,
          onPressed: onPrevious,
          icon: const Icon(
            Icons.skip_previous_rounded,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        PlayPauseButton(
          iconSize: playPauseIconSize,
          onPlayPause: onPlayPause,
          state: state,
        ),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          iconSize: nextIconSize,
          onPressed: onNext,
          icon: const Icon(
            Icons.skip_next_rounded,
          ),
        ),
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final double? iconSize;
  final ActivityState state;
  final OnPlayPause? onPlayPause;
  final Color? color;

  const PlayPauseButton({
    super.key,
    this.iconSize,
    required this.state,
    required this.onPlayPause, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      icon: AnimatedIconByState(
        animatedIconData: AnimatedIcons.pause_play,
        state: state == ActivityState.paused,
        color: color,
      ),
      onPressed: () async {
        await onPlayPause?.call(state.opposite);
      },
    );
  }
}
