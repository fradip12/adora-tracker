import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';

class CAnimatedLogo extends StatefulWidget {
  const CAnimatedLogo({this.onAnimationComplete, super.key});

  final VoidCallback? onAnimationComplete;

  @override
  State<CAnimatedLogo> createState() => _CAnimatedLogoState();
}

class _CAnimatedLogoState extends State<CAnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glow = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward().then((_) {
      _glowCtrl.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return Container(
          width: context.logoSize * 2,
          height: context.logoSize * 2,
          decoration: BoxDecoration(
            shape: .circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2 * _glow.value),
                blurRadius: 40 + (20 * _glow.value),
                spreadRadius: 10 * _glow.value,
              ),
            ],
          ),
          child: FadeScaleTransition(
            animation: _entryCtrl,
            child: Hero(
              tag: 'logo',
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: context.logoSize * 2,
                height: context.logoSize * 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
