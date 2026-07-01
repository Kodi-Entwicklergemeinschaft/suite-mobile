import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/utils/validation_helper.dart';
import '../../controller/profile_controller.dart';
import '../../controller/edit_profile_controller.dart';
import '../../state/edit_profile_state.dart';
import '../widgets/profile_avatar_widget.dart';

class EditProfileScreen extends BaseStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  String get screenName => AppRouteConstants.editProfile.name;

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
  final _loader = LoadingDialog();
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

    // Hide the avatar URL when the user has marked it for deletion.
    final avatarUrl = editState.pendingDelete
        ? null
        : profileState.data?.avatarUrl;

    ref.listen<EditProfileState>(editProfileControllerProvider, (
      previous,
      next,
    ) {
      next.isLoading ? _loader.show(context) : _loader.hide();
      if (next.isSuccess) {
        final message = next.successMessage?.isNotEmpty == true
            ? next.successMessage!
            : 'profile_updated'.tr;
        AppSnackBar.showSuccess(context, message);
        context.pop();
      }
      if (next.error != null) {
        AppSnackBar.showError(context, next.error!.tr);
      }
    });

    return Scaffold(
      appBar: CommonAppBar(
        title: 'edit_profile'.tr,
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
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
                  // Show delete only when there is an avatar to delete and it
                  // hasn't already been marked for deletion.
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
                    label: 'username'.tr,
                    controller: _usernameController,
                    filled: false,
                    readOnly: true,
                  ),
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  label: 'first_name'.tr,
                  filled: false,
                  controller: _firstNameController,
                  validator: ValidationHelper.validateName,
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  label: 'last_name'.tr,
                  controller: _lastNameController,
                  filled: false,
                  validator: ValidationHelper.validateName,
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  label: 'email'.tr,
                  controller: _emailController,
                  filled: false,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  label: 'website'.tr,
                  hintText: 'input_website'.tr,
                  filled: false,
                  controller: _websiteController,
                  validator: ValidationHelper.validateWebsite,
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  label: 'information'.tr,
                  hintText: 'input_information'.tr,
                  controller: _informationController,
                  filled: false,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                SizedBox(height: 32.h),
                AppButton(
                  'confirm'.tr,
                  width: double.maxFinite,
                  onPressed: _handleSubmit,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
