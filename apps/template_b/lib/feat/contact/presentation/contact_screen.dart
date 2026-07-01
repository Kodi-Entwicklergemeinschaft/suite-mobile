import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import 'package:template_b/feat/contact/controller/contact_controller.dart';
import 'package:theme/theme.dart';

class ContactScreen extends BaseStatefulWidget {
  const ContactScreen({super.key});

  @override
  String get screenName => AppRouteConstants.contact.name;

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends BaseStatefulWidgetState<ContactScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController firstNameTEC = TextEditingController();
  TextEditingController lastNameTEC = TextEditingController();
  TextEditingController phoneNumberTEC = TextEditingController();
  TextEditingController messageTEC = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneNumberFocus = FocusNode();
  final _messageFocus = FocusNode();

  @override
  void dispose() {
    emailTEC.dispose();
    firstNameTEC.dispose();
    lastNameTEC.dispose();
    phoneNumberTEC.dispose();
    messageTEC.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneNumberFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'contact_us'.tr),
      body: _buildBody(context, appTheme),
    );
  }

  Widget? _buildBody(BuildContext context, AppTheme appTheme) {
    final state = ref.watch(contactControllerProvider);
    final contactUsUrl = appTheme.assets?.contactUsUrl;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (contactUsUrl != null &&
                                  contactUsUrl.isNotEmpty) ...[
                                25.verticalSpace,
                                ExcludeSemantics(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CommonImage(
                                      imagePath: contactUsUrl,
                                      width: double.infinity,
                                      height: 230.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                              32.verticalSpace,
                              CommonTextField(
                                label: 'first_name'.tr,
                                controller: firstNameTEC,
                                focusNode: _firstNameFocus,
                                hintText: 'first_name'.tr,
                                filled: false,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    ValidationHelper.validateName(value),
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_lastNameFocus),
                              ),
                              32.verticalSpace,
                              CommonTextField(
                                label: 'last_name'.tr,
                                controller: lastNameTEC,
                                focusNode: _lastNameFocus,
                                hintText: 'last_name'.tr,
                                filled: false,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    ValidationHelper.validateName(value),
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_emailFocus),
                              ),
                              32.verticalSpace,
                              CommonTextField(
                                label: 'email'.tr,
                                controller: emailTEC,
                                focusNode: _emailFocus,
                                hintText: 'input_email'.tr,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    ValidationHelper.validateEmail(value),
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_phoneNumberFocus),
                              ),
                              32.verticalSpace,
                              CommonTextField(
                                label: 'phone_number'.tr,
                                controller: phoneNumberTEC,
                                focusNode: _phoneNumberFocus,
                                hintText: 'phone_number'.tr,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    ValidationHelper.validatePhoneNumber(value),
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_messageFocus),
                              ),
                              32.verticalSpace,
                              CommonTextField(
                                label: 'message'.tr,
                                controller: messageTEC,
                                focusNode: _messageFocus,
                                hintText: 'enter_message'.tr,
                                minLines: 3,
                                maxLines: 7,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                validator: (value) =>
                                    ValidationHelper.validateField(value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 24.h,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            'submit'.tr,
                            onPressed: () {
                              _handleSubmit(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final controller = ref.watch(contactControllerProvider.notifier);

    if (_formKey.currentState!.validate()) {
      controller.submitForm(
        email: emailTEC.text,
        firstName: firstNameTEC.text,
        phoneNumber: phoneNumberTEC.text,
        lastName: lastNameTEC.text,
        message: messageTEC.text,
        onSuccess: (String p1) {
          AppSnackBar.showSuccess(context, 'form_submit'.tr);
          clearField();
        },
        onError: (String p1) {
          AppSnackBar.showError(context, p1);
        },
      );
    }
  }

  void clearField() {
    emailTEC.clear();
    firstNameTEC.clear();
    phoneNumberTEC.clear();
    lastNameTEC.clear();
    messageTEC.clear();
  }
}
