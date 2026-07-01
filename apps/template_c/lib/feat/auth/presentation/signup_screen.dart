import 'dart:ui';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/locale.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/validation_helper.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/auth/controllers/signup_controller.dart';
import 'package:template_c/core/widgets/custom_input_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends BaseStatefulWidget {
  const SignupScreen({super.key});

  @override
  String get screenName => RouteConstant.signup.name;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends BaseStatefulWidgetState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _usernameFocus.addListener(() => _onFocus(_usernameFocus));
    _emailFocus.addListener(() => _onFocus(_emailFocus));
    _passwordFocus.addListener(() => _onFocus(_passwordFocus));
    _confirmPasswordFocus.addListener(() => _onFocus(_confirmPasswordFocus));
  }

  void _onFocus(FocusNode node) {
    if (node.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          node.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _handlePointerDown(PointerDownEvent event) {
    final result = HitTestResult();
    WidgetsBinding.instance.renderView.hitTest(
      result,
      position: event.position,
    );
    if (result.path.any((entry) => entry.target is RenderEditable)) return;
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

  void _handleSignUp() {
    _dismissKeyboard();
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(signupControllerProvider.notifier)
          .signUp(
            userName: _usernameController.text.trim().toLowerCase(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            confirmPassword: _confirmPasswordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signupControllerProvider, (previous, next) {
      if (previous?.state == next.state) return;
      if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message?.tr ?? 'error'.tr);
      }
      if (previous?.state != StateEnum.success &&
          next.state == StateEnum.success) {
        AppSnackBar.showSuccess(context, 'auth_signup_success'.tr);
        context.pushReplacementNamed(RouteConstant.signin.name);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final isLoading = state.state.isLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Stack(
        children: [
          //1st layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: context.templateColors.splashGradient,
              ),
            ),
          ),

          //2nd layer
          Positioned(
            top: 320.h,
            left: 0,
            right: 0,
            height: screenHeight,
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.9)
                  : Theme.of(context).scaffoldBackgroundColor,
            ),
          ),

          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      CommonText(
                        titleText: "back".tr,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SizedBox(height: 24.h),
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 60.h, bottom: 60),
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: Column(
                  children: [
                    // Title
                    Center(
                      child: CommonText(
                        titleText: "auth_signup_title".tr,
                        textStyle: context
                            .templateColors
                            .secondaryTextTheme
                            ?.bodyMedium
                            ?.copyWith(
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 0.9,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // "Already have an account?" row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          titleText: "auth_signup_have_account".tr,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.4,
                            letterSpacing: -0.01,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pushReplacementNamed(
                            RouteConstant.signin.name,
                          ),
                          child: CommonText(
                            titleText: "auth_signup_signin".tr,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              height: 1.4,
                              letterSpacing: -0.01,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 27.h),

                    // Form card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0x14000000)
                                  : Colors.white.withValues(alpha: 0.05),
                              blurRadius: 54,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0x80EBEBEB),
                            width: 1,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInputField(
                                labelTitle: "auth_signup_username_label".tr,
                                hintText: "auth_signup_username_hint".tr,
                                isRequired: true,
                                controller: _usernameController,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                validator: ValidationHelper.validateUsername,
                                focusNode: _usernameFocus,
                                onSubmitted: (_) => _emailFocus.requestFocus(),
                              ),
                              SizedBox(height: 24.h),
                              CustomInputField(
                                labelTitle: "auth_signup_email_label".tr,
                                hintText: "auth_signup_email_hint".tr,
                                isRequired: true,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: ValidationHelper.validateEmail,
                                focusNode: _emailFocus,
                                onSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                              ),
                              SizedBox(height: 24.h),
                              CustomInputField(
                                labelTitle: "auth_password_label".tr,
                                hintText: "auth_password_hint".tr,
                                isRequired: true,
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                suffixIcon: true,
                                suffixOnPressed: () {
                                  final savedOffset =
                                      _passwordController.selection.baseOffset;
                                  setState(
                                    () => _showPassword = !_showPassword,
                                  );
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    final maxOffset =
                                        _passwordController.text.length;
                                    _passwordController
                                        .selection = TextSelection.collapsed(
                                      offset: savedOffset.clamp(0, maxOffset),
                                    );
                                  });
                                },
                                obscureText: !_showPassword,
                                validator: ValidationHelper.validatePassword,
                                focusNode: _passwordFocus,
                                onSubmitted: (_) =>
                                    _confirmPasswordFocus.requestFocus(),
                              ),
                              SizedBox(height: 24.h),
                              CustomInputField(
                                labelTitle:
                                    "auth_signup_confirm_password_label".tr,
                                hintText:
                                    "auth_signup_confirm_password_hint".tr,
                                isRequired: true,
                                controller: _confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                suffixIcon: true,
                                suffixOnPressed: () {
                                  final savedOffset = _confirmPasswordController
                                      .selection
                                      .baseOffset;
                                  setState(
                                    () => _showConfirmPassword =
                                        !_showConfirmPassword,
                                  );
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    final maxOffset =
                                        _confirmPasswordController.text.length;
                                    _confirmPasswordController
                                        .selection = TextSelection.collapsed(
                                      offset: savedOffset.clamp(0, maxOffset),
                                    );
                                  });
                                },
                                obscureText: !_showConfirmPassword,
                                validator: (value) =>
                                    ValidationHelper.validateConfirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                                focusNode: _confirmPasswordFocus,
                                onSubmitted: (_) {
                                  if (!isLoading) _handleSignUp();
                                },
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //button
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(top: BorderSide(color: Color(0xFFEBEBEB))),
              ),
              child: IgnorePointer(
                ignoring: isLoading,
                child: AppButton(
                   "auth_signup_button".tr,
                  borderRadius: 100.r,
                  onPressed: () {
                    if (!isLoading) _handleSignUp();
                  },
                
                ),
              ),
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
            ),
        ],
      ),
    );
  }
}
