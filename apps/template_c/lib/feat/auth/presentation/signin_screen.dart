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
import 'package:template_c/feat/auth/controllers/signin_controller.dart';
import 'package:template_c/core/widgets/custom_input_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:go_router/go_router.dart';

class SigninScreen extends BaseStatefulWidget {
  const SigninScreen({super.key});

  @override
  String get screenName => RouteConstant.signin.name;

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends BaseStatefulWidgetState<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    _usernameFocus.addListener(() => _onFocus(_usernameFocus));
    _passwordFocus.addListener(() => _onFocus(_passwordFocus));
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

  void _handleSignIn() {
    _dismissKeyboard();

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(signinControllerProvider.notifier)
          .signIn(
            userNameOrEmail: _usernameOrEmailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signinControllerProvider, (previous, next) {
      if (previous?.state == next.state) return;
      if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message ?? 'error'.tr);
      }
      if (previous?.state != StateEnum.success &&
          next.state == StateEnum.success) {
        AppSnackBar.showSuccess(context, 'auth_signin_success'.tr);
        if (next.isOnboarded == true) {
          context.goNamed(RouteConstant.bottomNav.name);
        } else {
          context.goNamed(
            RouteConstant.locationOnboarding.name,
            extra: LocationOnboardingParams(
              isSkip: true,
              onConfirm: (context) {
                context.pushNamed(
                  RouteConstant.interestSelection.name,
                  extra: InterestSelectionParams(
                    isSkip: true,
                    onConfirm: (context) {
                      context.goNamed(RouteConstant.bottomNav.name);
                    },
                  ),
                );
              },
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = ref.watch(signinControllerProvider);
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
                        titleText: "auth_signin_title".tr,
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

                    // "Don't have an account?" row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          titleText: "auth_signin_no_account".tr,
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
                            RouteConstant.signup.name,
                          ),
                          child: CommonText(
                            titleText: "auth_signin_create_account".tr,
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
                                labelTitle:
                                    "auth_signin_username_or_email_label".tr,
                                hintText:
                                    "auth_signin_username_or_email_hint".tr,
                                isRequired: true,
                                controller: _usernameOrEmailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                validator: ValidationHelper.validateField,
                                focusNode: _usernameFocus,
                                onSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                              ),
                              SizedBox(height: 24.h),
                              CustomInputField(
                                labelTitle: "auth_password_label".tr,
                                hintText: "auth_password_hint".tr,
                                isRequired: true,
                                controller: _passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
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
                                onSubmitted: (_) {
                                  if (!isLoading) _handleSignIn();
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
                   "auth_signin_button".tr,
                   borderRadius: 100.r,
                    onPressed: () {
                    if (!isLoading) _handleSignIn();
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
