part of '../utils.dart';
class PageTransitions<T> extends PageRouteBuilder<T> {
  final bool shouldTransitionTo;
  final bool shouldTransitionFrom;

  PageTransitions.sharedAxis({
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 550),
    super.reverseTransitionDuration = const Duration(milliseconds: 450),
    Color? fillColor,
    SharedAxisTransitionType transitionType =
        SharedAxisTransitionType.horizontal,
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog = true,
    super.allowSnapshotting = true,
    this.shouldTransitionTo = true,
    this.shouldTransitionFrom = true,
  }) : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              fillColor: fillColor,
              child: child,
            );
          },
        );

  PageTransitions.fadeScale({
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 550),
    super.reverseTransitionDuration = const Duration(milliseconds: 450),
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.shouldTransitionTo = true,
    this.shouldTransitionFrom = true,
  }) : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeScaleTransition(
              animation: animation,
              child: child,
            );
          },
        );

  PageTransitions.fade({
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 550),
    super.reverseTransitionDuration = const Duration(milliseconds: 450),
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.shouldTransitionTo = true,
    this.shouldTransitionFrom = true,
  }) : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );

  PageTransitions.none({
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 550),
    super.reverseTransitionDuration = const Duration(milliseconds: 450),
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.shouldTransitionTo = true,
    this.shouldTransitionFrom = true,
  }) : super(
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return child;
          },
        );

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is PageRoute && shouldTransitionTo;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute && shouldTransitionFrom;
}
