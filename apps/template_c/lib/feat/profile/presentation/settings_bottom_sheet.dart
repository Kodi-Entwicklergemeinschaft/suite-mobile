import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/profile/controllers/delete_account_controller.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:template_c/feat/profile/state/delete_account_state.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:template_c/router/route_constant.dart';
import 'package:theme/theme.dart';
import 'package:template_c/feat/profile/controllers/settings_controller.dart';
import 'package:template_c/feat/profile/state/settings_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => const SettingsBottomSheet(),
  );
}

class SettingsBottomSheet extends BaseStatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  ConsumerState<SettingsBottomSheet> createState() =>
      _SettingBottonSheetState();
}

class _SettingBottonSheetState extends BaseStatefulWidgetState<SettingsBottomSheet> {
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
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final deleteState = ref.watch(deleteAccountControllerProvider);
    final appColors = ref.watch(appThemeProvider).colors;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = appColors.getTextColor(isDark);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor = appColors.dividerColor;
    final primaryColor = appColors.primary;

    final isGuest =
        ref
            .read(preferenceManagerProvider)
            .getStringOrEmpty(StorageKeys.authRole) ==
        UserRole.guest.value;

    ref.listen<DeleteAccountState>(deleteAccountControllerProvider, (
      previous,
      next,
    ) {
      if (next.error != null && next.error != previous?.error) {
        AppSnackBar.showError(context, next.error ?? 'error'.tr);
      }
      if (previous?.isSuccess != true && next.isSuccess) {
        AppSnackBar.showSuccess(context, 'delete_account_success'.tr);
        context.goNamed(RouteConstant.onboarding.name);
      }
    });

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
          ),
          child: Column(
            children: [
              CommonBottomSheetHeader(
                title: 'profile'.tr,
                showBackButton: true,
                onBack: () => Navigator.of(context, rootNavigator: true).pop(),
                onClose: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(textColor),
                      const SizedBox(height: 48),
                      _buildMainSection(
                        context,
                        settings,
                        controller,
                        dividerColor,
                        primaryColor,
                        textColor,
                        isGuest,
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottom(context, textColor, dividerColor),
            ],
          ),
        ),
        if (deleteState.isLoading)
          const Positioned.fill(
            child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
          ),
      ],
    );
  }

  // ─── Section title ─────────────────────────────────────────────────────────

  Widget _buildTitle(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CommonText(
        titleText: 'settings'.tr,
        textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ─── Settings list ─────────────────────────────────────────────────────────

  Widget _buildMainSection(
    BuildContext context,
    SettingsState settings,
    SettingsController controller,
    Color dividerColor,
    Color primaryColor,
    Color textColor,
    bool isGuest,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              if (!isGuest) ...[
                CommonMenuRow(
                  iconWidget: SvgPicture.asset(
                    'assets/svg/settings_icon.svg',
                    width: 20.sp,
                    height: 20.sp,
                    colorFilter: ColorFilter.mode(
                      textColor, // match your theme
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'edit_profile'.tr,
                  onTap: () {
                    context.pushNamed(RouteConstant.editProfile.name);
                  },
                ),
                const SizedBox(height: 32),
              ],
              if (!isGuest) ...[
                CommonMenuRow(
                  iconWidget: SvgPicture.asset(
                    'assets/svg/faq_icon.svg',
                    width: 20.sp,
                    height: 20.sp,
                    colorFilter: ColorFilter.mode(
                      textColor, // match your theme
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'login_security'.tr,
                  onTap: () {
                    context.pushNamed(RouteConstant.changePassword.name);
                  },
                ),
                const SizedBox(height: 32),
              ],
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/privacy_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'accessibility'.tr,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              // Dark mode row — toggle instead of chevron
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/dark_mode_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'dark_mode'.tr,
                trailing: CommonSwitchToggle(
                  value: settings.darkModeEnabled,
                  onChanged: (val) => controller.toggleDarkMode(val),
                  activeColor: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        if (!isGuest) ...[
          Divider(color: dividerColor, height: 1, thickness: 1),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CommonMenuRow(
              iconWidget: SvgPicture.asset(
                'assets/svg/box_arrow_up.svg',
                width: 20.sp,
                height: 20.sp,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.error, // match your theme
                  BlendMode.srcIn,
                ),
              ),
              label: 'delete_account'.tr,
              onTap: () => _showDeleteConfirmDialog(context),
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  // ─── Bottom version ────────────────────────────────────────────────────────

  Widget _buildBottom(
    BuildContext context,
    Color textColor,
    Color dividerColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
          child: Divider(color: dividerColor, height: 1, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 36, 36, 36),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CommonText(
              titleText: 'Version 1.0.5',
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
