import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, error, info, warning }

class ToastService {
  /// Show a toast message with specified type
  static void showToast(
    String message, {
    ToastType type = ToastType.info,
    Color? backgroundColor,
  }) {
    final color = backgroundColor ?? _getColorForType(type);
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }

  /// Get color based on toast type
  static Color _getColorForType(ToastType type) {
    return switch (type) {
      ToastType.success => Colors.green,
      ToastType.error => Colors.red,
      ToastType.info => Colors.blue,
      ToastType.warning => Colors.orange,
    };
  }

  /// Show a success toast
  static void showSuccess(String message) {
    showToast(message, type: ToastType.success);
  }

  /// Show an error toast
  static void showError(String message) {
    showToast(message, type: ToastType.error);
  }

  /// Show an info toast
  static void showInfo(String message) {
    showToast(message, type: ToastType.info);
  }

  /// Show a warning toast
  static void showWarning(String message) {
    showToast(message, type: ToastType.warning);
  }
}