import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';
import '../../../core/config/app_router.dart';
import '../widgets/c_pill_nav_bar.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [HomeRoute(), HistoryRoute(), SettingsRoute()],
      extendBody: true,
      backgroundColor: AppColors.surfaceWhite,
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      bottomNavigationBuilder: (_, tabsRouter) =>
          CPillNavBar(tabsRouter: tabsRouter),
    );
  }
}
