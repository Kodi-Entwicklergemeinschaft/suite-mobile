import 'package:common_components/common_components.dart' hide CommonTextField;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/core/widgets/common_text_field.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:template_a/feat/user/profile/state/profile_state.dart';
import 'package:template_a/main.dart';
import 'package:template_a/router/route_constant.dart';

class ProfileEditScreen extends BaseStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  String get screenName => RouteConstant.userProfileEdit.name;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends BaseStatefulWidgetState<ProfileEditScreen> {
  late final TextEditingController _firstNameTEC;
  late final TextEditingController _lastNameTEC;

  @override
  void initState() {
    super.initState();
    _firstNameTEC = TextEditingController();
    _lastNameTEC = TextEditingController();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).loadProfileData();
    });
  }

  @override
  void dispose() {
    _firstNameTEC.dispose();
    _lastNameTEC.dispose();
    super.dispose();
  }

  void _syncControllers(ProfileState state) {
    if (_firstNameTEC.text != state.firstName) {
      _firstNameTEC.text = state.firstName;
    }
    if (_lastNameTEC.text != state.lastName) {
      _lastNameTEC.text = state.lastName;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileControllerProvider, (previous, next) {
      if (next.status == StateEnum.initial && previous?.status == StateEnum.loading) {
        _syncControllers(next);
      }
      if (next.status == StateEnum.success && next.message != null) {
        AppSnackBar.showSuccess(context, 'profile_update_success'.tr);
        ref.read(profileControllerProvider.notifier).resetMessageState();
      }
      if (next.status == StateEnum.errorSnackBar && next.message != null) {
        AppSnackBar.showError(
          context,
          next.message!.isEmpty ? 'general_err_message'.tr : next.message!,
        );
        ref.read(profileControllerProvider.notifier).resetMessageState();
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(profileControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'my_profile_data'.tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CommonTextField(
                    label: 'first_name'.tr,
                    controller: _firstNameTEC,
                    onChanged: (v) => ref
                        .read(profileControllerProvider.notifier)
                        .updateFirstName(v),
                    fillColor: TemplateAColors.textFieldLightColor,
                    labelTextColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(height: 16.h),
                  CommonTextField(
                    label: 'last_name'.tr,
                    controller: _lastNameTEC,
                    onChanged: (v) => ref
                        .read(profileControllerProvider.notifier)
                        .updateLastName(v),
                    fillColor: TemplateAColors.textFieldLightColor,
                    labelTextColor: colorScheme.onSurface,
                    hintTextColor: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(height: 32.h),
                  AppButton(
                    'submit'.tr,
                    type: ButtonType.normal,
                    size: ButtonSize.large,
                    loading: state.isSubmitting,
                    bgColor: TemplateAColors.primary,
                    fontSize: 20.sp,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ref
                          .read(profileControllerProvider.notifier)
                          .updateProfile();
                    },
                  ),
                ],
              ),
            ),
    );
  }
}