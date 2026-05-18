import 'package:flutter/material.dart';

class GlobalTypewriterText extends StatelessWidget {
  const GlobalTypewriterText({
    required this.text,
    required this.animation,
    required this.style,
    super.key,
  });

  final String text;
  final Animation<double> animation;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final chars = text.characters.toList();
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final count = (animation.value * chars.length).round();
        final visible = chars.take(count).join();
        return Text(visible, style: style, textAlign: .center);
      },
    );
  }
}
