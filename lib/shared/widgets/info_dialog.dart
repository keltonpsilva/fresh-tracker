import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A utility class for showing informational dialogs throughout the app
class InfoDialog {
  /// Shows an informational dialog with a title and message
  ///
  /// [context] - The build context
  /// [title] - The title of the dialog
  /// [message] - The message content to display
  /// [buttonText] - Optional custom text for the OK button (defaults to "OK")
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a confirmation dialog with title, message, and confirm/cancel actions
  ///
  /// [context] - The build context
  /// [title] - The title of the dialog
  /// [message] - The message content to display
  /// [confirmText] - Text for the confirm button (defaults to "Confirm")
  /// [cancelText] - Text for the cancel button (defaults to "Cancel")
  /// [onConfirm] - Callback when the user confirms
  /// [onCancel] - Optional callback when the user cancels
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    if (Platform.isIOS || Platform.isMacOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }
}
