import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'common_text.dart';

class LoadingDialog {
  BuildContext? _ctx;
  static bool _isLoading = false;

  void show(BuildContext context, [String? message]) {
    if (!_isLoading) {
      _isLoading = true;

      // Unfocus any active text field to hide keyboard
      FocusManager.instance.primaryFocus?.unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          _ctx = context;
          return PopScope(
            canPop: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: CommonText(
                        titleText: message,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ).then((_) {
        _ctx = null;
        _isLoading = false;
      });
    }
  }

  void hide() {
    if (_isLoading && _ctx != null) {
      try {
        if (_ctx!.mounted && _ctx!.canPop()) {
          _ctx!.pop();
        }
      } catch (e) {
        debugPrint('Error hiding loading dialog: $e');
      } finally {
        _isLoading = false;
        _ctx = null;
      }
    }
  }
}
