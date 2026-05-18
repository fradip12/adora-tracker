import 'dart:async';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/components/theme/app_typography.dart';
import '../../../core/config/app_di.dart';
import '../../../core/config/app_router.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../data/misc/models/ripple.dart';
import '../../../data/misc/models/wizard_slide.dart';
import '../../../data/settings/services/settings_service.dart';
import '../managers/wizard_permission_bloc.dart';
import '../widgets/c_permission_prompter.dart';
import '../widgets/c_ripple_overlay.dart';
import '../widgets/c_squircle_button.dart';

@RoutePage()
class WizardPage extends StatelessWidget {
  const WizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<WizardPermissionBloc>()..add(const .init()),
      child: const _WizardView(),
    );
  }
}

class _WizardView extends StatefulWidget {
  const _WizardView();

  @override
  State<_WizardView> createState() => _WizardViewState();
}

class _WizardViewState extends State<_WizardView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ripple;
  int _displayPage = 0;
  List<int> _pageStack = [0];
  SlideData? _incomingSlide;
  PendingRipple? _rippleData;

  List<SlideData> get _slides => wizardSlides;

  int get _lastIndex => _slides.length - 1;

  bool _isStepGranted(WizardPermissionState active, int step) {
    if (step == 0) return active.locationGranted;
    if (step == 1) return active.notificationGranted;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ripple.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<WizardPermissionBloc>().add(const .refreshStatuses());
    }
  }

  Future<void> _onNext(
    WizardPermissionState active,
    Offset buttonCenter,
  ) async {
    if (_ripple.isAnimating || !_isStepGranted(active, active.currentStep)) {
      return;
    }

    final bloc = context.read<WizardPermissionBloc>();

    if (active.currentStep == _lastIndex) {
      unawaited(HapticHelper.lightImpact());
      bloc.add(const WizardPermissionEvent.complete());
      return;
    }

    unawaited(HapticHelper.selectionClick());
    final nextIdx = active.currentStep + 1;

    setState(() {
      _pageStack = [nextIdx, active.currentStep];
      _incomingSlide = _slides[nextIdx];
      _displayPage = nextIdx;
    });

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    await _runRipple(buttonCenter, _slides[nextIdx].bg, () {
      _pageStack = [nextIdx];
      _incomingSlide = null;
    });

    bloc.add(const WizardPermissionEvent.nextStep());
  }

  Future<void> _runRipple(
    Offset center,
    Color color,
    VoidCallback advance,
  ) async {
    final size = MediaQuery.of(context).size;
    final dx = math.max(center.dx, size.width - center.dx);
    final dy = math.max(center.dy, size.height - center.dy);
    final radius = math.sqrt(dx * dx + dy * dy);

    setState(() {
      _rippleData = PendingRipple(center: center, color: color, radius: radius);
    });

    await _ripple.forward(from: 0);

    if (!mounted) return;
    setState(() {
      advance();
      _rippleData = null;
    });
    _ripple.reset();
  }

  Offset _centerOf(BuildContext c) {
    final box = c.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft + Offset(box.size.width / 2, box.size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WizardPermissionBloc, WizardPermissionState>(
      listenWhen: (prev, curr) => curr.isComplete && !prev.isComplete,
      listener: (context, state) {
        locator<SettingsService>().setOnboardingDone();
        context.router.replaceAll([const RootRoute()]);
      },
      builder: (context, state) {
        if (!state.active) return const SizedBox.shrink();

        final slide = _slides[state.currentStep];
        final isLast = state.currentStep == _lastIndex;
        final isReadySlide = _displayPage == _lastIndex;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: slide.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: SizedBox.expand(
              child: Stack(
                children: [
                  for (final idx in _pageStack)
                    Container(key: ValueKey(idx), color: _slides[idx].bg),

                  if (_rippleData != null)
                    CRippleOverlay(
                      controller: _ripple,
                      center: _rippleData!.center,
                      radius: _rippleData!.radius,
                      color: _rippleData!.color,
                    ),

                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: .symmetric(horizontal: context.l),
                        child: Center(
                          child: PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (child, primaryAnimation, secondaryAnimation) =>
                                    FadeThroughTransition(
                                      animation: primaryAnimation,
                                      secondaryAnimation: secondaryAnimation,
                                      fillColor: Colors.transparent,
                                      child: child,
                                    ),
                            child: isReadySlide
                                ? _ReadyContent(
                                    key: ValueKey(_lastIndex),
                                    foreground: _slides[_lastIndex].btn,
                                  )
                                : PermissionPrompter(
                                    key: ValueKey(_displayPage),
                                    index: _displayPage,
                                    foreground: _slides[_displayPage].btn,
                                    background: _slides[_displayPage].bg,
                                    granted: _isStepGranted(
                                      state,
                                      _displayPage,
                                    ),
                                    onAllow: () {
                                      context.read<WizardPermissionBloc>().add(
                                        WizardPermissionEvent.requestPermission(
                                          _displayPage,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Builder(
                            builder: (ctx) {
                              final granted = _isStepGranted(
                                state,
                                state.currentStep,
                              );
                              const disabledBg = AppColors.textDisabled;
                              const disabledIcon = Colors.white;
                              final activeBg = granted ? slide.btn : disabledBg;
                              final activeIcon = granted
                                  ? slide.icon
                                  : disabledIcon;
                              final nextStep = state.currentStep + 1;
                              final nextGranted = nextStep <= _lastIndex
                                  ? _isStepGranted(state, nextStep)
                                  : true;
                              final incomingBg = _incomingSlide == null
                                  ? null
                                  : (nextGranted
                                        ? _incomingSlide!.btn
                                        : disabledBg);
                              final incomingIcon = _incomingSlide == null
                                  ? null
                                  : (nextGranted
                                        ? _incomingSlide!.icon
                                        : disabledIcon);

                              return CSquircleButton(
                                color: activeBg,
                                iconColor: activeIcon,
                                incomingColor: incomingBg,
                                incomingIconColor: incomingIcon,
                                progress: _ripple,
                                isCheck: isLast,
                                onTap: () => _onNext(state, _centerOf(ctx)),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReadyContent extends StatefulWidget {
  const _ReadyContent({required this.foreground, super.key});

  final Color foreground;

  @override
  State<_ReadyContent> createState() => _ReadyContentState();
}

class _ReadyContentState extends State<_ReadyContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _stagger(double start, double end, Widget child) {
    final anim = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeScaleTransition(animation: anim, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return _stagger(
      0,
      0.6,
      Text(
        context.t.wizard.readyTitle,
        textAlign: .center,
        style: context.heading3.copyWith(color: widget.foreground),
      ),
    );
  }
}
