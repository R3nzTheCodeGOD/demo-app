import 'package:flutter/material.dart';

/// Merkezi SnackBar sınıfı.
enum SnackBarType { success, error, info }

class SnackbarHelper {
  static void show(BuildContext context, String message, SnackBarType type) {
    if (!context.mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = colorScheme.primary;
        break;
      case SnackBarType.error:
        backgroundColor = colorScheme.error;
        break;
      case SnackBarType.info:
        backgroundColor = colorScheme.secondary;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
