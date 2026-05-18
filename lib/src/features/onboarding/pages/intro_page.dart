import 'dart:async';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/interactive/global_text_writer.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/components/theme/app_typography.dart';
import '../../../core/config/app_router.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../data/misc/models/intro_slide.dart';

@RoutePage()
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  static const _typewriterCharDuration = Duration(milliseconds: 16);
  static const _slideHoldDuration = Duration(milliseconds: 1400);
  static const _typeTickEvery = 3;

  late final AnimationController _typeController;
  Timer? _advanceTimer;
  int _index = 0;
  int _lastTickedChar = 0;

  @override
  void initState() {
    super.initState();
    _typeController = AnimationController(vsync: this)
      ..addStatusListener(_onTypeStatus)
      ..addListener(_onTypeTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrentSlide());
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _typeController
      ..removeStatusListener(_onTypeStatus)
      ..removeListener(_onTypeTick)
      ..dispose();
    super.dispose();
  }

  void _playCurrentSlide() {
    final desc = introSlides(context)[_index].description;
    _lastTickedChar = 0;
    unawaited(HapticHelper.lightImpact());
    _typeController
      ..stop()
      ..duration = _typewriterCharDuration * desc.characters.length
      ..forward(from: 0);
  }

  void _onTypeTick() {
    final slides = introSlides(context);
    final total = slides[_index].description.characters.length;
    if (total == 0) return;
    final count = (_typeController.value * total).round();
    if (count <= _lastTickedChar) return;
    if (count - _lastTickedChar >= _typeTickEvery || count == total) {
      _lastTickedChar = count;
      unawaited(HapticHelper.selectionClick());
    }
  }

  void _onTypeStatus(AnimationStatus status) {
    final slides = introSlides(context);
    if (status != AnimationStatus.completed) return;
    if (_index >= slides.length - 1) return;
    _advanceTimer?.cancel();
    _advanceTimer = Timer(_slideHoldDuration, () {
      if (!mounted) return;
      setState(() => _index += 1);
      unawaited(HapticHelper.selectionClick());
      _playCurrentSlide();
    });
  }

  void _goToWizard() {
    unawaited(HapticHelper.lightImpact());
    unawaited(context.router.replaceAll([const WizardRoute()]));
  }

  @override
  Widget build(BuildContext context) {
    final slides = introSlides(context);
    final isLast = _index == slides.length - 1;
    final current = slides[_index];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Padding(
          padding: .all(context.l),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: .min,
                    spacing: context.l,
                    children: [
                      PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, primary, secondary) =>
                            FadeThroughTransition(
                              animation: primary,
                              secondaryAnimation: secondary,
                              fillColor: Colors.transparent,
                              child: child,
                            ),
                        child: Text(
                          current.title,
                          key: ValueKey<int>(_index),
                          style: context.heading1.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 30,
                          ),
                          textAlign: .center,
                        ),
                      ),
                      GlobalTypewriterText(
                        key: ValueKey<int>(_index),
                        text: current.description,
                        animation: _typeController,
                        style: context.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: .centerRight,
                child: TextButton(
                  onPressed: _goToWizard,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: .symmetric(
                      horizontal: context.s,
                      vertical: context.xs,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    spacing: context.xxs,
                    children: [
                      Text(
                        isLast
                            ? context.t.intro.getStarted
                            : context.t.intro.skip,
                        style: context.bodyMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: .w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
