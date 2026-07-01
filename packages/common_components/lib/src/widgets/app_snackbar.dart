import 'package:flutter/material.dart';
import 'package:theme/theme.dart';
import 'common_text.dart';

class AppSnackBar {
  /// Shows a basic snackbar with the given message
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CommonText(titleText: message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an error snackbar with error color from theme
  static void showError(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;
    final appTheme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: _snackBarContent(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: appTheme.colorScheme.error,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        duration: const Duration(seconds: 20),
      ),
    );
  }

  /// Shows a success snackbar with success color from theme
  static void showSuccess(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;
    final errorColors = Theme.of(context).extension<AppErrorColors>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: _snackBarContent(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorColors?.success ?? Colors.green,
      ),
    );
  }

  /// Shows a warning snackbar with warning color from theme
  static void showWarning(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;
    final errorColors = Theme.of(context).extension<AppErrorColors>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: _snackBarContent(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorColors?.warning ?? Colors.amber,
      ),
    );
  }

  static Widget _snackBarContent(String message) {
    return CommonText(
      titleText: message.replaceAll('Exception:', ''),
      overflow: TextOverflow.visible,
      textStyle: TextStyle(color: Colors.white),
    );
  }
}
