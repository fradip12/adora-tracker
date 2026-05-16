import 'package:flutter/widgets.dart';

extension AppSpacing on BuildContext {
  EdgeInsets get pagePadding => const EdgeInsets.symmetric(horizontal: 24);

  double get xxs => 4;
  double get xs => 8;
  double get s => 12;
  double get m => 16;
  double get l => 24;
  double get xl => 32;
  double get xxl => 48;

  double get radiusSmall => 8;
  double get radiusMedium => 16;
  double get radiusLarge => 20;
  double get radiusXLarge => 32;

  double get buttonHeight => 56;
  double get logoSize => 64;

  double get deviceWidth => MediaQuery.sizeOf(this).width;
  double get deviceHeight => MediaQuery.sizeOf(this).height;

  double fsp(num value) => value * (MediaQuery.sizeOf(this).width / 375.0);
}

extension AppSpace on double {
  Widget get vSpace => SizedBox(height: this);
  Widget get hSpace => SizedBox(width: this);
}
