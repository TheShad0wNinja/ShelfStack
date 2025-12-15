import 'package:flutter/material.dart';

enum NotificationType {
  success,
  error,
  info,
  warning,
}

/// A helper class for showing consistent snack notifications across the app.
class SnackNotificationHelper {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnack(context, message, NotificationType.success, duration);
  }

  /// Show an error snack notification.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnack(context, message, NotificationType.error, duration);
  }

  /// Show an info snack notification.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnack(context, message, NotificationType.info, duration);
  }

  /// Show a warning snack notification.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnack(context, message, NotificationType.warning, duration);
  }

  /// Show multiple error messages as separate snacks.
  static void showErrors(
    BuildContext context,
    List<String> messages, {
    Duration duration = const Duration(seconds: 4),
  }) {
    for (final message in messages) {
      showError(context, message, duration: duration);
    }
  }

  static void _showSnack(
    BuildContext context,
    String message,
    NotificationType type,
    Duration duration,
  ) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade600;
        textColor = Colors.white;
        icon = Icons.info;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
      ),
    );
  }
}
