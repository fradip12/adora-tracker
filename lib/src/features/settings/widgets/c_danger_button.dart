import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../core/components/theme/app_spacing.dart';
import '../../../core/extension/ext_misc.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  Future<void> _showConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.settings.clearDataConfirmTitle),
        content: Text(context.t.settings.clearDataConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => context.maybePop(false),
            child: Text(context.t.settings.clearDataConfirmCancel),
          ),
          TextButton(
            onPressed: () => context.maybePop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(context.t.settings.clearDataConfirmDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConfirmDialog(context),
      child: Container(
        padding: const .symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacityPercent(5),
          border: .all(color: AppColors.danger),
          borderRadius: .circular(context.m),
        ),
        alignment: .center,
        child: Text(
          context.t.settings.clearData,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: .w600,
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}
