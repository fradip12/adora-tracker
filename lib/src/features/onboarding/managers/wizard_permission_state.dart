part of 'wizard_permission_bloc.dart';

@freezed
abstract class WizardPermissionState with _$WizardPermissionState {
  const factory WizardPermissionState({
    @Default(false) bool active,
    @Default(0) int currentStep,
    @Default(false) bool locationGranted,
    @Default(false) bool isRequestingPermission,
    @Default(false) bool isComplete,
  }) = _WizardPermissionState;
}
