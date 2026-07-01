import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_b/feat/dashbboard/controller/dashboard_controller.dart';
import 'package:template_b/feat/profile/controller/profile_controller.dart';
import 'package:template_b/routes/app_routes.dart';
import '../widgets/menu_item_widget.dart';
import '../../controller/delete_account_controller.dart';

class ProfileSettingsScreen extends BaseStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  String get screenName => AppRouteConstants.profileSettings.name;

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState
    extends BaseStatefulWidgetState<ProfileSettingsScreen> {
  final _loader = LoadingDialog();

  void _showDeleteConfirmDialog(BuildContext context) {
    final userId = ref.read(profileControllerProvider).data?.id;
    CommonSheet.showConfirmation(
      context,
      title: 'delete_account'.tr,
      content: 'delete_account_confirm'.tr,
      onConfirm: () {
        ref
            .read(deleteAccountControllerProvider.notifier)
            .deleteAccount(userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deleteAccountControllerProvider, (previous, next) {
      next.isLoading ? _loader.show(context) : _loader.hide();

      if (previous?.isSuccess != true && next.isSuccess) {
        AppSnackBar.showSuccess(context, 'delete_account_success'.tr);
        if (!context.mounted) return;
        context.goNamed(AppRouteConstants.splash.name);
        ref.read(bottomNavigationProvider.notifier).setSelectedIndex(0);
      } else if (next.error != null && previous?.error != next.error) {
        AppSnackBar.showError(context, next.error!.tr);
      }
    });

    return Scaffold(
      appBar: CommonAppBar(
        title: 'profile_settings'.tr,
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MenuItemWidget(
              title: 'edit_profile'.tr,
              onTap: () =>
                  context.pushNamed(AppRouteConstants.editProfile.name),
            ),
            MenuItemWidget(
              title: 'change_password'.tr,
              onTap: () =>
                  context.pushNamed(AppRouteConstants.changePassword.name),
            ),
            MenuItemWidget(
              title: 'delete_account'.tr,
              onTap: () => _showDeleteConfirmDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
