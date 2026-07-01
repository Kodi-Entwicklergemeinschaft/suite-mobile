import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;
import 'package:theme/theme.dart';

import '../../../core/common_components.dart';
import '../controllers/auth_controller.dart';
import '../../onboarding/controller/onboarding_controller.dart';

enum AuthMode { login, register, resetPassword }

class AuthPage extends BaseStatefulWidget {
  const AuthPage({super.key, this.initialMode = AuthMode.register});

  final AuthMode initialMode;

  @override
  String get screenName => switch (initialMode) {
        AuthMode.login => RouteConstant.signin.name,
        AuthMode.register => 'register',
        AuthMode.resetPassword => 'reset_password',
      };

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends BaseStatefulWidgetState<AuthPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  late AuthMode _authMode;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialMode;
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleAuthMode(AuthMode mode) {
    // login ↔ register: navigate to the other page (push replacement effect)
    if (mode == AuthMode.login && widget.initialMode == AuthMode.register) {
      ref.read(onboardingControllerProvider.notifier).onPageChanged(3);
      return;
    }
    if (mode == AuthMode.register && widget.initialMode == AuthMode.login) {
      ref.read(onboardingControllerProvider.notifier).onPageChanged(2);
      return;
    }
    // resetPassword ↔ login: in-place state toggle
    setState(() => _authMode = mode);
    ref.read(onboardingControllerProvider.notifier).setResetPasswordActive(mode == AuthMode.resetPassword);
    _slideController.reset();
    _slideController.forward();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      switch (_authMode) {
        case AuthMode.login:
          ref.read(authControllerProvider.notifier).login(
                email: email,
                password: password,
              );
        case AuthMode.register:
          ref.read(authControllerProvider.notifier).register(
                email: email,
                password: password,
              );
        case AuthMode.resetPassword:
          ref.read(authControllerProvider.notifier).forgotPassword(
                email: email,
              );
      }
    }
  }

  bool _isFormValid() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    switch (_authMode) {
      case AuthMode.login:
        return email.isNotEmpty && password.isNotEmpty;
      case AuthMode.register:
        return email.isNotEmpty && password.isNotEmpty;
      case AuthMode.resetPassword:
        return email.isNotEmpty;
    }
  }

  String _getTitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'registration_title'.tr;
      case AuthMode.register:
        return 'registration_title'.tr;
      case AuthMode.resetPassword:
        return 'password_reset_title'.tr;
    }
  }

  String _getSubtitle() {
    final appId = ref.watch(appThemeProvider).title ?? '';
    switch (_authMode) {
      case AuthMode.login:
        return 'login_subtitle'.trParams({'appId': appId});
      case AuthMode.register:
        return 'registration_subtitle'.trParams({'appId': appId});
      case AuthMode.resetPassword:
        return '';
    }
  }

  String _getEmailLabel() {
    switch (_authMode) {
      case AuthMode.login:
        return 'login_email_label'.tr;
      case AuthMode.register:
        return 'register_email_label'.tr;
      case AuthMode.resetPassword:
        return 'reset_password_email_label'.tr;
    }
  }

  String _getPasswordLabel() {
    return _authMode == AuthMode.login
        ? 'login_password_label'.tr
        : 'register_password_label'.tr;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _authMode == AuthMode.login
          ? 'login_email_validation_empty'.tr
          : 'register_email_validation_empty'.tr;
    }
    if (!RegExp(r'^.+@.+\..+$').hasMatch(value)) {
      return 'login_email_validation_invalid'.tr;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _authMode == AuthMode.login
          ? 'login_password_validation_empty'.tr
          : 'register_password_validation_empty'.tr;
    }
    return null;
  }

  void _onEmailSubmitted() {
    if (_authMode == AuthMode.resetPassword) {
      _handleSubmit();
    } else {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    }
  }

  void _onPasswordSubmitted() {
    _handleSubmit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.state == StateEnum.success && next.message != null) {
        if (_authMode == AuthMode.resetPassword || _authMode == AuthMode.register) {
          AppSnackBar.showSuccess(context, next.message!);
          _toggleAuthMode(AuthMode.login);
        } else {
          // login success — skip all onboarding only if already onboarded on backend
          if (next.isOnboarded == true) {
            context.go(ref.read(shellConfigProvider.notifier).firstTabPath);
          } else {
            context.goNamed(RouteConstant.termsConditions.name);
          }
        }
        ref.read(authControllerProvider.notifier).resetState();
      } else if (next.state == StateEnum.errorSnackBar && next.message != null) {
        AppSnackBar.showError(context, next.message!);
        ref.read(authControllerProvider.notifier).resetState();
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildSubtitle(),
          SizedBox(height: 10.h),
          _buildForm(),
          _buildActionLinks(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Semantics(
      header: true,
      child: CommonText(
        textAlign: TextAlign.center,
        titleText: _getTitle(),
        textScaler: TextScaler.noScaling,
        textStyle: TextStyle(
          color: ref.watch(appThemeProvider).colors.fontLight,
          fontSize: _authMode == AuthMode.resetPassword ? 24.w : 28.w,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return CommonText(
      titleText: _getSubtitle(),
      maxLines: 5,
      textAlign: TextAlign.center,
      textScaler: TextScaler.noScaling,
      textStyle: TextStyle(
        color: ref.watch(appThemeProvider).colors.fontLight,
        fontSize: 24.w,
        fontWeight: FontWeight.w500,
        height: 0.9,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 8.h,
        children: [
          _buildEmailField(),
          if (_authMode != AuthMode.resetPassword) _buildPasswordField(),
        ],
      ),
    );
  }

  // Kiel-style dark card textfield (shared across all auth fields).
  static const _fieldFillColor = Color(0xFF2C4158);
  static const _fieldHintColor = Color(0xB3FFFFFF); // white @ 70%

  Widget _buildEmailField() {
    return SlideTransition(
      position: _slideAnimation,
      child: CommonTextField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _onEmailSubmitted(),
        label: _getEmailLabel(),
        fillColor: _fieldFillColor,
        hintTextColor: _fieldHintColor,
        labelTextColor: Colors.white,
        validator: _validateEmail,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        suffixIcon: _emailController.text.isNotEmpty
            ? CommonIcon(
                icon: Icons.cancel,
                color: Colors.white,
                label: 'clear_email_tooltip'.tr,
                onPressed: () {
                  _emailController.clear();
                  setState(() {});
                },
              )
            : null,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SlideTransition(
      position: _slideAnimation,
      child: CommonTextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _onPasswordSubmitted(),
        label: _getPasswordLabel(),
        fillColor: _fieldFillColor,
        hintTextColor: _fieldHintColor,
        labelTextColor: Colors.white,
        obscureText: !_isPasswordVisible,
        validator: _validatePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        suffixIcon: CommonIcon(
          color: Colors.white,
          label: _isPasswordVisible
              ? 'hide_password_tooltip'.tr
              : 'show_password_tooltip'.tr,
          icon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }


  Widget _buildActionLinks() {
    return Column(
      children: [
        _buildSecondaryAction(),
        SizedBox(height: 4.h),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildNextButton() {
    final authState = ref.watch(authControllerProvider);
    final isValid = _isFormValid();
    return AppButton(
      'next'.tr,
      type: ButtonType.normal,
      size: ButtonSize.large,
      disabled: !isValid,
      loading: authState.state == StateEnum.loading,
      onPressed: _handleSubmit,
      bgColor: isValid
          ? Theme.of(context).colorScheme.secondary
          : const Color(0xFF2C4158),
      fontSize: 20.sp,
    );
  }

  Widget _buildSecondaryAction() {
    final linkColor = Theme.of(context).colorScheme.secondary;
    final linkStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: linkColor,
    );

    switch (_authMode) {
      case AuthMode.login:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: TextButton(
                onPressed: () => _toggleAuthMode(AuthMode.resetPassword),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(8.w, 40.h, 8.w, 8.h),
                ),
                child: Text('password_reset_title'.tr, style: linkStyle, textAlign: TextAlign.start),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () => _toggleAuthMode(AuthMode.register),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(8.w, 40.h, 8.w, 8.h),
                ),
                child: Text('login_no_account_register'.tr, style: linkStyle, textAlign: TextAlign.end),
              ),
            ),
          ],
        );
      case AuthMode.register:
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _toggleAuthMode(AuthMode.login),
            child: Text('login_already_registered_login'.tr, style: linkStyle),
          ),
        );
      case AuthMode.resetPassword:
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _toggleAuthMode(AuthMode.login),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text('remember_password_login_again'.tr, style: linkStyle),
          ),
        );
    }
  }
}
