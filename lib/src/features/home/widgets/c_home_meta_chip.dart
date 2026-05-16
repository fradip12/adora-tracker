import 'package:flutter/material.dart';

import '../../../core/components/theme/app_colors.dart';

class HomeMetaChip extends StatelessWidget {
  const HomeMetaChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
