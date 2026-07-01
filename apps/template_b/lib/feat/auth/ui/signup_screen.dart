import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/common_enums.dart';
import 'package:template_b/feat/auth/controller/signup_controller.dart';
import 'package:template_b/feat/auth/state/signup_state.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import 'package:template_b/routes/app_routes.dart';

class SignUpScreen extends BaseStatefulWidget {
  const SignUpScreen({super.key});

  @override
  String get screenName => AppRouteConstants.signUp.name;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends BaseStatefulWidgetState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _emailFocus = FocusNode();

  final _loader = LoadingDialog();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isUsernameFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(_onUsernameFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
  }

  void _onUsernameFocusChange() {
    setState(() => _isUsernameFocused = _usernameFocus.hasFocus);
  }

  void _onPasswordFocusChange() {
    setState(() => _isPasswordFocused = _passwordFocus.hasFocus);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _usernameFocus.removeListener(_onUsernameFocusChange);
    _passwordFocus.removeListener(_onPasswordFocusChange);
    _usernameFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(signUpControllerProvider.notifier)
          .signUp(
            username: _usernameController.text.trim().toLowerCase(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            confirmPassword: _confirmPasswordController.text.trim(),
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

  void _toggleConfirmPasswordVisibility() {
    final savedOffset = _confirmPasswordController.selection.baseOffset;
    setState(() => _showConfirmPassword = !_showConfirmPassword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final maxOffset = _confirmPasswordController.text.length;
      _confirmPasswordController.selection = TextSelection.collapsed(
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

  @override
  Widget build(BuildContext context) {
    ref.listen<SignUpState>(signUpControllerProvider, (previous, next) {
      if (previous?.state == next.state) return;
      next.state == StateEnum.loadingDialog
          ? _loader.show(context)
          : _loader.hide();

      if (next.isSuccess && next.message != null) {
        AppSnackBar.showSuccess(context, next.message);
        context.pop();
      } else if (next.state == StateEnum.errorSnackBar) {
        AppSnackBar.showError(context, next.message?.tr ?? 'error'.tr);
      }
    });

    final state = ref.watch(signUpControllerProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'sign_up'.tr),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),

                    // Username Section
                    CommonTextField(
                      label: 'username'.tr,
                      hintText: 'input_id'.tr,
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      textInputAction: TextInputAction.next,
                      validator: ValidationHelper.validateUsername,
                      onSubmitted: (_) => _firstNameFocus.requestFocus(),
                    ),
                    if (_isUsernameFocused) _buildHint('username_hint'.tr),
                    SizedBox(height: 19.h),

                    // First Name Section
                    CommonTextField(
                      label: 'first_name'.tr,
                      hintText: 'input_fname'.tr,
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      textInputAction: TextInputAction.next,
                      validator: ValidationHelper.validateName,
                      onSubmitted: (_) => _lastNameFocus.requestFocus(),
                    ),
                    SizedBox(height: 19.h),

                    // Last Name Section
                    CommonTextField(
                      label: 'last_name'.tr,
                      hintText: 'input_lname'.tr,
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      textInputAction: TextInputAction.next,
                      validator: ValidationHelper.validateName,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    SizedBox(height: 19.h),

                    // Password Section
                    CommonTextField(
                      label: 'password'.tr,
                      hintText: 'input_your_password'.tr,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.next,
                      validator: ValidationHelper.validatePassword,
                      suffixIcon: _buildVisibilityToggle(
                        _showPassword,
                        _togglePasswordVisibility,
                      ),
                      onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                    ),
                    if (_isPasswordFocused) _buildHint('password_hint'.tr),
                    SizedBox(height: 19.h),

                    // Confirm Password Section
                    CommonTextField(
                      label: 'confirm_password'.tr,
                      hintText: 'input_your_cpassword'.tr,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      obscureText: !_showConfirmPassword,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          ValidationHelper.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                      suffixIcon: _buildVisibilityToggle(
                        _showConfirmPassword,
                        _toggleConfirmPasswordVisibility,
                      ),
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    SizedBox(height: 19.h),

                    // Email Section
                    CommonTextField(
                      label: 'email'.tr,
                      hintText: 'input_email'.tr,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: ValidationHelper.validateEmail,
                      onSubmitted: (_) => _handleSignUp(),
                    ),
                    SizedBox(height: 16.h),

                    // Sign Up Button
                    AppButton(
                      'sign_up'.tr,
                      mainAxisSize: MainAxisSize.max,
                      onPressed: _handleSignUp,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHint(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: isVisible
          ? 'hide_password_tooltip'.tr
          : 'show_password_tooltip'.tr,
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            size: 22.h,
          ),
        ),
      ),
    );
  }
}
