import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../components/theme/app_spacing.dart';

extension OverlayExt on BuildContext {
  void showToast(
    String title, {
    String? description,
    ToastificationType type = ToastificationType.info,
    Duration autoClose = const Duration(seconds: 4),
  }) {
    toastification.show(
      context: this,
      type: type,
      style: .simple,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: .bottomCenter,
      autoCloseDuration: autoClose,
      borderRadius: .circular(m),
      borderSide: .none,
      showProgressBar: false,
      closeOnClick: true,
      dragToClose: true,
      showIcon: true,
      closeButton: const ToastCloseButton(showType: .none),
    );
  }
}
