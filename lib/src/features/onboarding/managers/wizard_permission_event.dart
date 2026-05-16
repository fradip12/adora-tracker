part of 'wizard_permission_bloc.dart';

@freezed
abstract class WizardPermissionEvent with _$WizardPermissionEvent {
  const factory WizardPermissionEvent.init() = _Init;
  const factory WizardPermissionEvent.requestPermission(int slideIndex) =
      _RequestPermission;
  const factory WizardPermissionEvent.refreshStatuses() = _RefreshStatuses;
  const factory WizardPermissionEvent.nextStep() = _NextStep;
  const factory WizardPermissionEvent.complete() = _Complete;
}
