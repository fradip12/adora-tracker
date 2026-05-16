import 'package:flutter/services.dart';

class HapticHelper {
  HapticHelper._();

  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> errorVibrate() async {
    await HapticFeedback.vibrate();
  }
}
