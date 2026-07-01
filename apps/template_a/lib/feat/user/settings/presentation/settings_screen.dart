import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:theme/theme.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:template_a/feat/user/account/controller/account_controller.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:template_a/feat/user/settings/presentation/notification_prefs_screen.dart';
import 'package:template_a/feat/user/settings/presentation/reset_password_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_language_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_theme_screen.dart';
import 'package:template_a/feat/user/settings/widgets/section_tile.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_controller.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_state.dart';
import 'package:template_a/router/route_constant.dart';
import '../../../../core/constant/image.dart';

class SettingsScreen extends BaseStatelessWidget {
  const SettingsScreen({super.key});

  @override
  String get screenName => RouteConstant.userSettings.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
    ref.watch(profileControllerProvider);
    final legalState = ref.watch(termsControllerProvider);
    if (legalState.status == TermsStatusEnum.initial) {
      Future.microtask(() => ref.read(termsControllerProvider.notifier).getLatestTerms());
    }
    final prefs = ref.watch(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;
    final accountController = ref.read(accountControllerProvider.notifier);

    return AppScaffold(
      appBar: const CommonAppBar(showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10.h,
            children: [
              CommonText(
                titleText: 'setting'.tr.toUpperCase(),
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SectionTile(
                'language'.tr,
                iconImage: Images.languageIcon,
                onTap: () {
                  try {
                    context.pushNamed('profile_user_settings_language');
                  } catch (_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
                    );
                  }
                },
                label: 'language'.tr,
              ),
              SectionTile(
                'accessibility'.tr,
                icon: Icons.accessibility_new,
                onTap: () => context.pushNamed(
                  RouteConstant.webView.name,
                  extra: CommonWebViewWidgetParams(
                    url: 'https://example.com/accessibility',
                    title: 'accessibility'.tr,
                    showCloseButton: true,
                    appBarHeight: 64,
                  ),
                ),
                label: 'accessibility'.tr,
              ),
              if (!isGuest)
                SectionTile(
                  'notifications'.tr,
                  icon: Icons.notifications,
                  onTap: () {
                    try {
                      context.pushNamed('profile_user_settings_notifications');
                    } catch (_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationPrefsScreen()),
                      );
                    }
                  },
                  label: 'notifications'.tr,
                ),
              if (legalState.privacyUrl.isNotEmpty)
                SectionTile(
                  'privacy_policy'.tr,
                  iconImage: Images.privacyIcon,
                  onTap: () => context.pushNamed(
                    RouteConstant.webView.name,
                    extra: CommonWebViewWidgetParams(
                      url: legalState.privacyUrl,
                      title: 'privacy_policy'.tr,
                      showCloseButton: true,
                      appBarHeight: 64,
                    ),
                  ),
                  label: 'privacy_policy'.tr,
                ),
              if (legalState.imprintUrl.isNotEmpty)
                SectionTile(
                  'imprint'.tr,
                  iconImage: Images.imprintIcon,
                  onTap: () => context.pushNamed(
                    RouteConstant.webView.name,
                    extra: CommonWebViewWidgetParams(
                      url: legalState.imprintUrl,
                      title: 'imprint'.tr,
                      showCloseButton: true,
                      appBarHeight: 64,
                    ),
                  ),
                  label: 'imprint'.tr,
                ),
              SectionTile(
                'app_theme'.tr,
                iconImage: Images.servicesIcon,
                onTap: () {
                  try {
                    context.pushNamed('profile_user_settings_theme');
                  } catch (_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectThemeScreen()),
                    );
                  }
                },
                label: 'app_theme'.tr,
              ),
              if (isFullyLoggedIn) ...[
                SectionTile(
                  'reset_password'.tr,
                  icon: Icons.password,
                  onTap: () {
                    try {
                      context.pushNamed('profile_user_settings_reset_password');
                    } catch (_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                      );
                    }
                  },
                  label: 'reset_password'.tr,
                ),
                SectionTile(
                  'delete_account'.tr,
                  icon: Icons.delete,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                  label: 'delete_account'.tr,
                ),
              ],
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppContainerColors>()!.inverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: CommonText(
          titleText: 'delete_account_confirmation'.tr,
          textAlign: TextAlign.center,
          textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.normal),
        ),
        content: CommonText(titleText: 'delete_account_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: CommonText(
              titleText: 'cancel'.tr,
              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final deleted = await ref
                  .read(profileControllerProvider.notifier)
                  .deleteAccount();
              if (deleted && context.mounted) {
                context.goNamed(RouteConstant.onboarding.name);
              }
            },
            child: CommonText(
              titleText: 'delete'.tr,
              textStyle: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
