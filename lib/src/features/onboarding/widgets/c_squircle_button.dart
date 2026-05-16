import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CSquircleButton extends StatefulWidget {
  const CSquircleButton({
    required this.color,
    required this.iconColor,
    required this.progress,
    required this.isCheck,
    required this.onTap,
    this.incomingColor,
    this.incomingIconColor,
    super.key,
  });

  final Color color;
  final Color iconColor;
  final Color? incomingColor;
  final Color? incomingIconColor;
  final Animation<double> progress;
  final bool isCheck;
  final VoidCallback onTap;

  @override
  State<CSquircleButton> createState() => _CSquircleButtonState();
}

class _CSquircleButtonState extends State<CSquircleButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _entryCtrl;
  late final Animation<double> _rotation;

  static const Duration _colorAnim = Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rotation = Tween<double>(
      begin: 0,
      end: math.pi / 4,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: FadeScaleTransition(
          animation: _entryCtrl,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, child) =>
                Transform.rotate(angle: _rotation.value, child: child),
            child: AnimatedBuilder(
              animation: widget.progress,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(widget.progress.value);
                final targetBg = widget.incomingColor != null
                    ? Color.lerp(widget.color, widget.incomingColor, t)!
                    : widget.color;
                final targetIc = widget.incomingIconColor != null
                    ? Color.lerp(widget.iconColor, widget.incomingIconColor, t)!
                    : widget.iconColor;

                return TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: targetBg),
                  duration: _colorAnim,
                  curve: Curves.easeOut,
                  builder: (context, bg, _) => TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: targetIc),
                    duration: _colorAnim,
                    curve: Curves.easeOut,
                    builder: (context, ic, _) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: bg ?? targetBg,
                        borderRadius: .circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: .center,
                      child: AnimatedBuilder(
                        animation: _rotation,
                        builder: (context, child) => Transform.rotate(
                          angle: -_rotation.value,
                          child: child,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            widget.isCheck
                                ? Icons.check_rounded
                                : Icons.chevron_right_rounded,
                            key: ValueKey(widget.isCheck),
                            color: ic ?? targetIc,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
