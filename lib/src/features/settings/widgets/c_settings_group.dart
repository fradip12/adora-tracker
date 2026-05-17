import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(
          const Divider(height: 0, thickness: 1, color: AppColors.borderLight),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: .all(color: AppColors.border),
        borderRadius: .circular(18),
      ),
      clipBehavior: .hardEdge,
      child: Column(children: separated),
    );
  }
}
