import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_di.dart';

part 'wizard_permission_bloc.freezed.dart';
part 'wizard_permission_event.dart';
part 'wizard_permission_state.dart';

const _kOnboardingCompleteKey = 'onboarding_complete';

@injectable
class WizardPermissionBloc
    extends Bloc<WizardPermissionEvent, WizardPermissionState> {
  final SharedPreferences _prefs;

  WizardPermissionBloc(this._prefs) : super(const WizardPermissionState()) {
    on<_Init>((event, emit) async {
      final loc = await Permission.locationWhenInUse.status;
      final notif = Platform.isIOS
          ? await Permission.notification.status
          : PermissionStatus.granted;
      emit(
        WizardPermissionState(
          active: true,
          locationGranted: loc.isGranted || loc.isLimited,
          notificationGranted: notif.isGranted,
        ),
      );
    });

    on<_RequestPermission>((event, emit) async {
      if (!state.active || state.isRequestingPermission) return;

      emit(state.copyWith(isRequestingPermission: true));

      if (event.slideIndex == 0) {
        await _requestLocation(emit);
      } else if (event.slideIndex == 1 && Platform.isIOS) {
        await _requestNotification(emit);
      }

      emit(state.copyWith(isRequestingPermission: false));
    });

    on<_RefreshStatuses>((event, emit) async {
      if (!state.active) return;

      final loc = await Permission.locationWhenInUse.status;
      final notif = Platform.isIOS
          ? await Permission.notification.status
          : PermissionStatus.granted;
      emit(
        state.copyWith(
          locationGranted: loc.isGranted || loc.isLimited,
          notificationGranted: notif.isGranted,
        ),
      );
    });

    on<_NextStep>((event, emit) {
      if (!state.active) return;
      emit(state.copyWith(currentStep: state.currentStep + 1));
    });

    on<_Complete>((event, emit) async {
      if (!state.active) return;
      await _prefs.setBool(_kOnboardingCompleteKey, true);
      emit(state.copyWith(isComplete: true));
    });
  }

  static bool isOnboardingComplete() {
    return locator<SharedPreferences>().getBool(_kOnboardingCompleteKey) ??
        false;
  }

  Future<void> _requestLocation(Emitter<WizardPermissionState> emit) async {
    final current = await Permission.locationWhenInUse.status;
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    final status = await Permission.locationWhenInUse.request();
    if (state.active) {
      emit(
        state.copyWith(locationGranted: status.isGranted || status.isLimited),
      );
    }
  }

  Future<void> _requestNotification(Emitter<WizardPermissionState> emit) async {
    final current = await Permission.notification.status;
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    final status = await Permission.notification.request();
    if (state.active) {
      emit(state.copyWith(notificationGranted: status.isGranted));
    }
  }
}
