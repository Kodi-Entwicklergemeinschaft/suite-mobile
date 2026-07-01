import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/locale.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/profile/controller/profile_controller.dart';

/// Wraps [child] and listens to [profileControllerProvider] for logout flow:
/// shows loading dialog and success/error snackbars. Use on any screen that
/// can trigger logout (e.g. My Profile, Home with drawer, Services with drawer).
class LogoutListener extends BaseStatefulWidget {
  const LogoutListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<LogoutListener> createState() =>
      _LogoutListenerState();
}

class _LogoutListenerState extends BaseStatefulWidgetState<LogoutListener> {
  final _loader = LoadingDialog();

  @override
  Widget build(BuildContext context) {
    ref.listen(profileControllerProvider, (previous, next) {
      if (previous?.state == next.state) return;

      next.state == StateEnum.loadingDialog
          ? _loader.show(context)
          : _loader.hide();

      if (next.state == StateEnum.success &&
          previous?.state == StateEnum.loadingDialog) {
        AppSnackBar.showSuccess(context, next.message ?? 'logout_success'.tr);
      } else if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message ?? 'error'.tr);
      }
    });

    return widget.child;
  }
}
