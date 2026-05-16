import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../i18n/strings.g.dart';

class PermissionData {
  const PermissionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.button,
  });

  final IconData icon;
  final String title;
  final String description;
  final String button;
}

PermissionData locationPermission(BuildContext context) => PermissionData(
  icon: LucideIcons.mapPin,
  title: context.t.permission.locationTitle,
  description: context.t.permission.locationDescription,
  button: context.t.permission.locationButton,
);

PermissionData notificationPermission(BuildContext context) => PermissionData(
  icon: LucideIcons.bell,
  title: context.t.permission.notificationTitle,
  description: context.t.permission.notificationDescription,
  button: context.t.permission.notificationButton,
);
