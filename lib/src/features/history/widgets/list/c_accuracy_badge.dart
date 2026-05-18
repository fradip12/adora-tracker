import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../data/history/enums/accuracy_level.dart';

extension _AccuracyLevelColors on AccuracyLevel {
  Color get bgColor => switch (this) {
    .good => const Color(0xFFE8F5E9),
    .ok => const Color(0xFFFFFBEB),
    .warn => const Color(0xFFFEF2F2),
  };

  Color get textColor => switch (this) {
    .good => const Color(0xFF1B6E24),
    .ok => const Color(0xFF92400E),
    .warn => const Color(0xFF991B1B),
  };
}

class AccuracyBadge extends StatelessWidget {
  const AccuracyBadge({required this.accuracy, super.key});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final level = AccuracyLevel.fromMeters(accuracy);
    return Container(
      padding: const .symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: level.bgColor,
        borderRadius: .circular(6),
      ),
      child: Text(
        context.t.history.accuracyValue(meters: accuracy.toStringAsFixed(0)),
        style: TextStyle(
          fontSize: 10,
          fontWeight: .w700,
          color: level.textColor,
        ),
      ),
    );
  }
}
