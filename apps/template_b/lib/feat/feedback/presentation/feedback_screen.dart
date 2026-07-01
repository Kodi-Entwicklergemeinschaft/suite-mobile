import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import 'package:template_b/feat/feedback/controller/feedback_controller.dart';

class FeedbackScreen extends BaseStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  String get screenName => AppRouteConstants.feedback.name;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends BaseStatefulWidgetState<FeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController informationTEC = TextEditingController();

  final _emailFocus = FocusNode();
  final _informationFocus = FocusNode();

  @override
  void dispose() {
    emailTEC.dispose();
    informationTEC.dispose();
    _emailFocus.dispose();
    _informationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'feedback'.tr),
      body: _buildBody(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    final state = ref.watch(feedbackControllerProvider);

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
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            32.verticalSpace,
                            CommonTextField(
                              label: 'email'.tr,
                              controller: emailTEC,
                              focusNode: _emailFocus,
                              hintText: 'input_email'.tr,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidationHelper.validateEmail(value),
                              onSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_informationFocus),
                            ),
                            32.verticalSpace,
                            CommonTextField(
                              label: 'information'.tr,
                              controller: informationTEC,
                              focusNode: _informationFocus,
                              hintText: 'enter_your_feedback_here'.tr,
                              minLines: 3,
                              maxLines: 7,
                              filled: false,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              validator: (value) =>
                                  ValidationHelper.validateField(value),
                            ),
                          ],
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
    final controller = ref.watch(feedbackControllerProvider.notifier);

    if (_formKey.currentState!.validate()) {
      controller.submitForm(
        email: emailTEC.text,
        informatiom: informationTEC.text,
        onError: (String p1) {
          AppSnackBar.showError(context, p1.tr);
        },
        onSuccess: (String p1) {
          AppSnackBar.showSuccess(context, 'form_submit'.tr);
          clearFields();
        },
      );
    }
  }

  void clearFields() {
    emailTEC.clear();
    informationTEC.clear();
  }
}
