import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/locale.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:go_router/go_router.dart';

class SessionExpireDialog {
  SessionExpireDialog._();

  static bool _isShowing = false;
  static bool get isShowing => _isShowing;

  /// Shows the session expired dialog. Caller must ensure [context] is mounted.
  /// Safe to call multiple times — only one dialog will be shown at a time.
  static void show(BuildContext context, Ref ref) {
    if (_isShowing) return;
    _isShowing = true;
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          content: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Text(
              'session_expired_message'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                _isShowing = false;
                Navigator.of(dialogContext).pop();
                // Schedule after the dialog pop finishes its frame so the
                // widget tree is stable before go_router replaces the route.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.goNamed(RouteConstant.signin.name);
                  }
                });
              },
              child: Text('session_expired_login'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
