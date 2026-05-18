import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'i18n/strings.g.dart';
import 'src/core/config/app_di.dart';
import 'src/core/config/app_router.dart';
import 'src/features/home/managers/tracker_bloc.dart';

class AdoraApp extends StatefulWidget {
  const AdoraApp({super.key});

  @override
  State<AdoraApp> createState() => _AdoraAppState();
}

class _AdoraAppState extends State<AdoraApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: Builder(
        builder: (ctx) => BlocProvider(
          create: (context) => locator<TrackerBloc>(),
          child: MaterialApp.router(
            title: 'Adora',
            debugShowCheckedModeBanner: false,
            locale: TranslationProvider.of(ctx).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            routerConfig: _appRouter.config(),
            builder: (context, child) =>
                ToastificationWrapper(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
