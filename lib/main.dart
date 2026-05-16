import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'src/core/config/app_di.dart';
import 'src/core/utils/debug_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  Bloc.observer = MultiBlocObserver(
    observers: [if (kDebugMode) DebugBlocObserver()],
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const AdoraApp());
}
