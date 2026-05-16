import 'package:flutter/material.dart';

class GlobalAnimatedSwitcher extends StatelessWidget {
  const GlobalAnimatedSwitcher({
    this.useSizeTransition = true,
    this.duration,
    this.reverseDuration,
    this.transitionBuilder,
    this.child,
    super.key,
  });

  final bool useSizeTransition;
  final Duration? duration;
  final Duration? reverseDuration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? const Duration(milliseconds: 300),
      reverseDuration: reverseDuration ?? const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (child, animation) {
        if (transitionBuilder != null) {
          return transitionBuilder!(child, animation);
        }
        if (!useSizeTransition) {
          return FadeTransition(opacity: animation, child: child);
        }
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: child,
    );
  }
}
