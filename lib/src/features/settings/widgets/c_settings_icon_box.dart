import 'package:flutter/material.dart';

import '../../../core/components/theme/app_spacing.dart';

class SettingsIconBox extends StatelessWidget {
  const SettingsIconBox({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.xl + 8,
      height: context.xl + 8,
      decoration: BoxDecoration(color: bgColor, borderRadius: .circular(10)),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
}
