import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'app.dart';
import 'src/core/config/app_di.dart';
import 'src/core/utils/debug_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  await configureDependencies();

  Bloc.observer = MultiBlocObserver(
    observers: [if (kDebugMode) DebugBlocObserver()],
  );

  await SystemChrome.setPreferredOrientations([.portraitUp]);

  runApp(const AdoraApp());
}
