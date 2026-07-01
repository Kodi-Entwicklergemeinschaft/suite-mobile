import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/validation_helper.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/feat/profile/controllers/edit_profile_controller.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:template_c/feat/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:template_c/feat/profile/state/edit_profile_state.dart';
import 'package:template_c/router/route_constant.dart';

class EditProfileScreen extends BaseStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  String get screenName => RouteConstant.editProfile.name;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends BaseStatefulWidgetState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _informationController;

  late GlobalKey<FormState> _formKey;
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    final profileState = ref.read(profileControllerProvider);

    _usernameController = TextEditingController(
      text: profileState.data?.username ?? '',
    );
    _firstNameController = TextEditingController(
      text: profileState.data?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: profileState.data?.lastName ?? '',
    );
    _emailController = TextEditingController(
      text: profileState.data?.email ?? '',
    );
    _websiteController = TextEditingController(
      text: profileState.data?.website ?? '',
    );
    _informationController = TextEditingController(
      text: profileState.data?.information ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _informationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(editProfileControllerProvider.notifier)
          .submitForm(
            username: _usernameController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            website: _websiteController.text,
            information: _informationController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final editController = ref.read(editProfileControllerProvider.notifier);
    final isLoading = editState.state.isLoading;

    // Hide the avatar URL when the user has marked it for deletion.
    final avatarUrl = editState.pendingDelete ? null : profileState.data?.avatarUrl;

    ref.listen<EditProfileState>(editProfileControllerProvider, (
      previous,
      next,
    ) {
      if (next.state == StateEnum.error) {
        final errorMsg = (next.message != null && next.message!.isNotEmpty)
            ? next.message!.tr
            : 'something_went_wrong'.tr;
        AppSnackBar.showError(context, errorMsg);
        return;
      }
      if (previous?.state != StateEnum.success &&
          next.state == StateEnum.success) {
        final message =
            (next.message != null && next.message!.trim().isNotEmpty)
            ? next.message!.tr
            : 'profile_updated'.tr;
        AppSnackBar.showSuccess(context, message);
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      appBar: CommonAppBar(
        title: 'edit_profile'.tr,
        centerTitle: true,
        showBackButton: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    ProfileAvatarWidget(
                      avatarUrl: avatarUrl,
                      file: editState.file,
                      isUploadingImage: editState.isUploadingImage,
                      onTap: () async {
                        final file = await ref
                            .read(imagePickerControllerProvider.notifier)
                            .pickImageWithDialog(context);

                        if (file != null) {
                          debugPrint(
                            'SELECTED FILE SIZE = ${(file.lengthSync() / 1024 / 1024)} MB',
                          );
                          editController.updateFile(file);
                        }
                      },
                      onDeletePressed:
                          !editState.pendingDelete &&
                              ((avatarUrl != null && avatarUrl.isNotEmpty) ||
                                  editState.file != null)
                          ? () => editController.deleteAvatar()
                          : null,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      child: CommonTextField(
                        label: 'auth_signup_username_label'.tr,
                        controller: _usernameController,
                        filled: false,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CommonTextField(
                      label: 'profile_first_name_label'.tr,
                      filled: false,
                      controller: _firstNameController,
                      validator: ValidationHelper.validateName,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 16.h),
                    CommonTextField(
                      label: 'profile_last_name_label'.tr,
                      controller: _lastNameController,
                      filled: false,
                      validator: ValidationHelper.validateName,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 16.h),
                    CommonTextField(
                      label: 'auth_signup_email_label'.tr,
                      controller: _emailController,
                      filled: false,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    SizedBox(height: 16.h),
                    CommonTextField(
                      label: 'website'.tr,
                      controller: _websiteController,
                      filled: false,
                      keyboardType: TextInputType.url,
                      validator: ValidationHelper.validateWebsite,
                    ),
                    SizedBox(height: 16.h),
                    CommonTextField(
                      label: 'information'.tr,
                      controller: _informationController,
                      filled: false,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),

                    SizedBox(height: 32.h),
                    AppButton(
                      'confirm_button'.tr,
                      width: double.maxFinite,
                      onPressed: _handleSubmit,
                      borderRadius: 100.r,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
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
