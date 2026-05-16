import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/config/app_router.dart';
import '../widgets/c_animated_logo.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textCtrl.forward();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (!mounted) return;
    context.router.replaceAll([const IntroRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Center(child: CAnimatedLogo(onAnimationComplete: _navigateNext)),
    );
  }
}
