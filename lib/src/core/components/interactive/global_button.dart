import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum GlobalButtonVariant { primary, outlined, ghost }

class GlobalButton extends StatelessWidget {
  const GlobalButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = GlobalButtonVariant.primary,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isExpanded = true,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlobalButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? color;
  final Color? textColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          )
        : Row(
            mainAxisSize: isExpanded ? .max : .min,
            mainAxisAlignment: .center,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: context.s)],
              Text(label),
            ],
          );

    final minSize = Size(isExpanded ? double.infinity : 0, context.buttonHeight);

    switch (variant) {
      case GlobalButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            minimumSize: minSize,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(context.radiusMedium),
            ),
            textStyle: context.buttonText.copyWith(color: textColor ?? Colors.white),
          ),
          child: child,
        );
      case GlobalButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? color ?? AppColors.primary,
            side: BorderSide(color: color ?? AppColors.border),
            minimumSize: minSize,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(context.radiusMedium),
            ),
            textStyle: context.buttonText,
          ),
          child: child,
        );
      case GlobalButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? color ?? AppColors.primary,
            minimumSize: minSize,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(context.radiusMedium),
            ),
            textStyle: context.buttonText,
          ),
          child: child,
        );
    }
  }
}
