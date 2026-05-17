import '../../../../i18n/strings.g.dart';

enum AppLocaleOption {
  english,
  japanese;

  AppLocale get locale => switch (this) {
        .english => AppLocale.en,
        .japanese => AppLocale.ja,
      };

  String get nativeName => switch (this) {
        .english => 'English',
        .japanese => '日本語',
      };

  String get prefValue => name;

  static AppLocaleOption fromPrefValue(String value) =>
      values.firstWhere((e) => e.name == value, orElse: () => .english);

  static AppLocaleOption fromAppLocale(AppLocale locale) => switch (locale) {
        AppLocale.en => .english,
        AppLocale.ja => .japanese,
      };
}
