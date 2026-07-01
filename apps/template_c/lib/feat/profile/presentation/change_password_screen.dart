import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network/network.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/utils/validation_helper.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/profile/controllers/change_password_controller.dart';
import 'package:template_c/feat/profile/state/change_password_state.dart';
import 'package:template_c/feat/auth/domain/usecases/logout_usecase.dart';
import 'package:template_c/router/route_constant.dart';

class ChangePasswordScreen extends BaseStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  String get screenName => RouteConstant.changePassword.name;

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends BaseStatefulWidgetState<ChangePasswordScreen> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  late GlobalKey<FormState> _formKey;

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void handleSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(changePasswordControllerProvider.notifier)
        .submitPasswordChange(
          currentPassword: currentPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
        );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() => _showCurrentPassword = !_showCurrentPassword);
  }

  void _toggleNewPasswordVisibility() {
    setState(() => _showNewPassword = !_showNewPassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _showConfirmPassword = !_showConfirmPassword);
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        size: 22.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChangePasswordState>(changePasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next.state == StateEnum.errorSnackBar) {
        final errorMsg = (next.message != null && next.message!.isNotEmpty)
            ? next.message!
            : 'something_went_wrong'.tr;
        AppSnackBar.showError(context, errorMsg);
        return;
      }
      if (next.state == StateEnum.error) {
        final errorMsg = 'something_went_wrong'.tr;
        AppSnackBar.showError(context, errorMsg);
        return;
      }
      if (next.isSuccess) {
        AppSnackBar.showSuccess(
          context,
          'password_change_success_login_again'.tr,
        );
        ref.read(logoutUseCaseProvider).call(NoParams());
        context.goNamed(RouteConstant.onboarding.name);
      }
    });

    final state = ref.watch(changePasswordControllerProvider);
    final isLoading = state.state.isLoading;

    return Scaffold(
      appBar: CommonAppBar(
        title: 'change_password'.tr,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          CommonTextField(
                            controller: currentPasswordController,
                            focusNode: _currentPasswordFocus,
                            label: 'current_password'.tr,
                            hintText: 'enter_current_password'.tr,
                            obscureText: !_showCurrentPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: _buildVisibilityToggle(
                              _showCurrentPassword,
                              _toggleCurrentPasswordVisibility,
                            ),
                            validator: ValidationHelper.validateField,
                            onSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_newPasswordFocus),
                          ),
                          SizedBox(height: 20.h),
                          CommonTextField(
                            controller: newPasswordController,
                            focusNode: _newPasswordFocus,
                            label: 'new_password'.tr,
                            hintText: 'enter_new_password'.tr,
                            obscureText: !_showNewPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: _buildVisibilityToggle(
                              _showNewPassword,
                              _toggleNewPasswordVisibility,
                            ),
                            validator: (value) {
                              final baseError = ValidationHelper.validatePassword(
                                value,
                              );
                              if (baseError != null) return baseError;
                              if (value != null &&
                                  value == currentPasswordController.text) {
                                return 'error_same_password'.tr;
                              }
                              return null;
                            },
                            onSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_confirmPasswordFocus),
                          ),
                          SizedBox(height: 20.h),
                          CommonTextField(
                            controller: confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            label: 'confirm_password'.tr,
                            hintText: 'confirm_password'.tr,
                            obscureText: !_showConfirmPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: _buildVisibilityToggle(
                              _showConfirmPassword,
                              _toggleConfirmPasswordVisibility,
                            ),
                            validator: (value) {
                              return ValidationHelper.validateConfirmPassword(
                                value,
                                newPasswordController.text,
                              );
                            },
                            onSubmitted: (_) => handleSubmit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: AppButton(
                    'confirm'.tr,
                    width: double.maxFinite,
                    onPressed: handleSubmit,
                    borderRadius: 100.r,
                  ),
                ),
              ],
            ),
            if (isLoading)
              const Positioned.fill(
                child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
              ),
          ],
        ),
      ),
    );
  }
}
