import 'package:common_components/common_components.dart' hide CommonTextField;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:template_a/core/widgets/common_text_field.dart';
import 'package:template_a/feat/auth/controllers/forgot_password_controller.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:template_a/feat/user/profile/state/profile_state.dart';
import 'package:template_a/router/route_constant.dart';

class ResetPasswordScreen extends BaseStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  String get screenName => RouteConstant.userSettingsResetPassword.name;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends BaseStatefulWidgetState<ResetPasswordScreen> {
  late final TextEditingController _emailTEC;
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _loader = LoadingDialog();

  @override
  void initState() {
    super.initState();
    _emailTEC = TextEditingController(
      text: ref.read(profileControllerProvider).email ?? '',
    );
    if (_emailTEC.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(profileControllerProvider.notifier).loadProfileData();
      });
    }
  }

  @override
  void dispose() {
    _emailTEC.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      FocusScope.of(context).unfocus();
      ref.read(forgotPasswordControllerProvider.notifier).resetPassword(
            email: _emailTEC.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileControllerProvider, (prev, next) {
      if (prev?.email == null && next.email != null && _emailTEC.text.isEmpty) {
        _emailTEC.text = next.email!;
      }
    });

    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider, (prev, next) {
      next.state == StateEnum.loadingDialog
          ? _loader.show(context)
          : _loader.hide();

      if (next.isSuccess) {
        AppSnackBar.showSuccess(context, 'reset_link_send'.tr);
        context.pop();
      } else if (next.state == StateEnum.errorSnackBar && next.message != null) {
        AppSnackBar.showError(context, next.message!);
        ref.read(forgotPasswordControllerProvider.notifier).reset();
      }
    });

    return AppScaffold(
      appBar: const CommonAppBar(showBackButton: true),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10.h,
            children: [
              SizedBox(
                width: double.infinity,
                child: CommonText(
                  textAlign: TextAlign.start,
                  titleText: 'reset_password'.tr.toUpperCase(),
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              CommonTextField(
                controller: _emailTEC,
                focusNode: _emailFocus,
                label: 'reset_password_email_label'.tr,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                fillColor: TemplateAColors.textFieldLightColor,
                labelTextColor: Theme.of(context).colorScheme.onSurface,
                hintTextColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'login_email_validation_empty'.tr;
                  }
                  return null;
                },
                onSubmitted: (_) => _submit(),
              ),
              AppButton(
                'submit'.tr,
                type: ButtonType.normal,
                size: ButtonSize.small,
                height: 36.h,
                bgColor: TemplateAColors.primary,
                fontSize: 18.sp,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
