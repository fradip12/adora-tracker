import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';

import '../../features/history/pages/history_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/onboarding/pages/intro_page.dart';
import '../../features/onboarding/pages/splash_page.dart';
import '../../features/onboarding/pages/wizard_page.dart';
import '../../features/root/pages/root_page.dart';
import '../../features/settings/pages/settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 400),
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: IntroRoute.page),
    AutoRoute(page: WizardRoute.page),
    AutoRoute(
      page: RootRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: HistoryRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
  ];
}
