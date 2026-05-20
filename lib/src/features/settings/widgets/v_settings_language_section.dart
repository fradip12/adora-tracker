import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/components/theme/app_colors.dart';
import '../../../data/settings/enums/app_locale_option.dart';
import 'c_settings_group.dart';
import 'c_settings_row.dart';

class SettingsLanguageSection extends StatelessWidget {
  const SettingsLanguageSection({
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final AppLocaleOption locale;
  final ValueChanged<AppLocaleOption> onLocaleChanged;

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<AppLocaleOption>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LanguagePickerSheet(current: locale),
    );
    if (selected != null) onLocaleChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      children: [
        SettingsRow(
          icon: LucideIcons.globe,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primaryDark,
          name: context.t.settings.language,
          description: context.t.settings.languageDesc,
          onTap: () => _showLanguagePicker(context),
          trailing: Row(
            mainAxisSize: .min,
            spacing: 6,
            children: [
              Text(
                locale.nativeName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: .w500,
                  color: AppColors.textSecondary,
                ),
              ),

              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.current});

  final AppLocaleOption current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                context.t.settings.languageSelectTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: .w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(
              height: 0,
              thickness: 1,
              color: AppColors.borderLight,
            ),
            ...AppLocaleOption.values.map(
              (option) => ListTile(
                title: Text(option.nativeName),
                trailing: option == current
                    ? const Icon(LucideIcons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
