import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/controller/signin_controller.dart';
import 'package:template_b/feat/auth/state/signin_state.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_b/feat/profile/controller/profile_controller.dart';
import 'package:template_b/routes/app_routes.dart';

class SignInScreen extends BaseStatefulWidget {
  const SignInScreen({super.key});

  @override
  String get screenName => AppRouteConstants.signIn.name;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends BaseStatefulWidgetState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _loader = LoadingDialog();

  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(signInControllerProvider.notifier)
          .signIn(
            usernameOrEmail: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  void _togglePasswordVisibility() {
    final savedOffset = _passwordController.selection.baseOffset;
    setState(() => _showPassword = !_showPassword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final maxOffset = _passwordController.text.length;
      _passwordController.selection = TextSelection.collapsed(
        offset: savedOffset.clamp(0, maxOffset),
      );
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    final result = HitTestResult();
    WidgetsBinding.instance.renderView.hitTest(
      result,
      position: event.position,
    );

    // Tapping directly on the text editing area
    if (result.path.any((entry) => entry.target is RenderEditable)) return;

    // Tapping within the focused field's decoration (suffix/prefix icons, label)
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus?.context != null) {
      final formFieldState = primaryFocus!.context!
          .findAncestorStateOfType<FormFieldState<dynamic>>();
      if (formFieldState != null) {
        final fieldRenderBox =
            formFieldState.context.findRenderObject() as RenderBox?;
        if (fieldRenderBox != null && fieldRenderBox.hasSize) {
          final localPos = fieldRenderBox.globalToLocal(event.position);
          if (fieldRenderBox.size.contains(localPos)) return;
        }
      }
    }

    FocusScope.of(context).unfocus();
  }

  void _showInfoDialog() {
    CommonSheet.showWithChild(
      context,

      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Center(
              child: CommonText(
                titleText: 'info_title'.tr,
                isHeader: true,
                textStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            10.verticalSpace,
            Center(
              child: Text(
                'registration_instructions_title'.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              label: 'registration_step1_label'.tr,
              description: 'registration_step1_text'.tr,
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              label: 'registration_step2_label'.tr,
              description: 'registration_step2_text'.tr,
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              label: 'registration_step3_label'.tr,
              description: 'registration_step3_text'.tr,
            ),
            SizedBox(height: 12.h),
            _buildInfoItem(
              label: 'registration_step4_label'.tr,
              description: 'registration_step4_text'.tr,
            ),
            SizedBox(height: 12.h),
            // Closing text
            Text(
              'registration_closing_text'.tr,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: description,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          softWrap: true,
          maxLines: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SignInState>(signInControllerProvider, (previous, next) {
      if (previous?.state == next.state) return;

      next.state == StateEnum.loadingDialog
          ? _loader.show(context)
          : _loader.hide();

      if (next.isSuccess) {
        if (next.message != null) {
          AppSnackBar.showSuccess(context, next.message!);
        }

        context.goNamed(AppRouteConstants.bottomNavigation.name);
        ref.invalidate(profileControllerProvider);
        ref.read(bottomNavigationProvider.notifier).loadConfig();
        ref
            .read(bottomNavigationProvider.notifier)
            .setSelectedIndexBySlug(AppRouteConstants.myProfile.name);
        ref.read(bottomNavigationProvider.notifier).refreshIndexedStack();
      } else if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message ?? 'error'.tr);
      }
    });

    return Scaffold(
      appBar: CommonAppBar(
        title: 'sign_in'.tr,
        showBackButton: context.canPop(),
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                child: SingleChildScrollView(
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        // Username/Email Field
                        CommonTextField(
                          label: 'account_or_email'.tr,
                          hintText: 'account_or_email'.tr,
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          validator: ValidationHelper.validateField,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        SizedBox(height: 19.h),

                        // Password Field
                        CommonTextField(
                          label: 'password'.tr,
                          hintText: 'password'.tr,
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: !_showPassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          validator: ValidationHelper.validateField,
                          suffixIcon: Semantics(
                            button: true,
                            label: _showPassword
                                ? 'hide_password_tooltip'.tr
                                : 'show_password_tooltip'.tr,
                            child: GestureDetector(
                              onTap: _togglePasswordVisibility,
                              child: ExcludeSemantics(
                                child: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 22.h,
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _handleSignIn(),
                        ),
                        SizedBox(height: 16.h),

                        // Sign In Button
                        AppButton(
                          'sign_in'.tr,
                          mainAxisSize: MainAxisSize.max,
                          onPressed: _handleSignIn,
                        ),
                        SizedBox(height: 4.h),

                        // Forgot Password & Sign Up Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: AppButton(
                                textOverflow: TextOverflow.visible,
                                'forgot_password'.tr,
                                type: ButtonType.text,
                                onPressed: () => context.pushNamed(
                                  AppRouteConstants.forgotPassword.name,
                                ),
                              ),
                            ),
                            Flexible(
                              child: AppButton(
                                'sign_up'.tr,
                                type: ButtonType.text,
                                onPressed: () => context.pushNamed(
                                  AppRouteConstants.signUp.name,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Info Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              'info'.tr,
                              onPressed: _showInfoDialog,
                              type: ButtonType.text,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
