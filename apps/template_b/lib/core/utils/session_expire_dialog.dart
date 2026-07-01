import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/locale.dart';
import 'package:template_b/routes/router_provider.dart';
import 'package:go_router/go_router.dart';

class SessionExpireDialog {
  SessionExpireDialog._();

  static bool _isShowing = false;
  static bool get isShowing => _isShowing;

  /// Shows the session expired dialog. Caller must ensure [context] is mounted.
  /// Safe to call multiple times — only one dialog will be shown at a time.
  static void show(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Consumer(
          builder: (_, ref, __) => CupertinoAlertDialog(
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
                onPressed: () {
                  debugPrint('[SessionExpireDialog] use_as_guest tapped — invalidating router');
                  _isShowing = false;
                  ref.invalidate(goRouterProvider);
                },
                child: Text('use_as_guest'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
