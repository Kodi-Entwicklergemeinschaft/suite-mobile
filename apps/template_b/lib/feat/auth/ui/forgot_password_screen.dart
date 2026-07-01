import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/controller/forgot_password_controller.dart';
import 'package:template_b/feat/auth/state/forgot_password_state.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import 'package:template_b/routes/app_routes.dart';

class ForgotPasswordScreen extends BaseStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  String get screenName => AppRouteConstants.forgotPassword.name;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseStatefulWidgetState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _loader = LoadingDialog();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(forgotPasswordControllerProvider.notifier)
          .resetPassword(username: _usernameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider, (
      previous,
      next,
    ) {
      next.state == StateEnum.loadingDialog
          ? _loader.show(context)
          : _loader.hide();

      if (next.isSuccess) {
        AppSnackBar.showSuccess(
          context,
          next.message ?? 'forgot_password_success'.tr,
        );
        context.pop();
      } else if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message ?? 'error'.tr);
      }
    });

    final state = ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'forgot_password'.tr, centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonTextField(
                      label: 'account_or_email'.tr,
                      hintText: 'account_or_email'.tr,
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: ValidationHelper.validateField,
                      onSubmitted: (_) => _handleResetPassword(),
                    ),
                    SizedBox(height: 19.h),
                    AppButton(
                      'reset_password'.tr,
                      mainAxisSize: MainAxisSize.max,
                      onPressed: _handleResetPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
