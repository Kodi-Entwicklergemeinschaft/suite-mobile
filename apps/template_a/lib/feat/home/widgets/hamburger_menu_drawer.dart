import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/feat/auth/controllers/auth_controller.dart';
import 'package:template_a/feat/onboarding/controller/onboarding_controller.dart';
import 'package:template_a/feat/user/account/controller/account_controller.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:template_a/feat/user/profile/presentation/profile_edit_screen.dart';
import 'package:template_a/feat/user/settings/presentation/notification_prefs_screen.dart';
import 'package:template_a/feat/user/settings/presentation/reset_password_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_language_screen.dart';
import 'package:template_a/feat/user/settings/presentation/select_theme_screen.dart';
import 'package:template_a/core/utils/template_a_colors.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_controller.dart';
import 'package:template_a/feat/terms_conditions/controller/terms_state.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;
import 'package:theme/theme.dart';

class HamburgerMenuDrawer extends BaseStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HamburgerMenuDrawer({required this.navigationShell, super.key});

  @override
  ConsumerState<HamburgerMenuDrawer> createState() =>
      _HamburgerMenuDrawerState();
}

class _HamburgerMenuDrawerState extends BaseStatefulWidgetState<HamburgerMenuDrawer> {
  bool _profileExpanded = false;
  bool _helpExpanded = false;
  bool _legalExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferenceManagerProvider);
      final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
      final isGuest = prefs.getBool(StorageKeys.authIsGuest);
      if (isLoggedIn && !isGuest) {
        final profileState = ref.read(profileControllerProvider);
        if (profileState.firstName.isEmpty && profileState.email == null) {
          ref.read(profileControllerProvider.notifier).loadProfileData();
        }
      }
      if (ref.read(termsControllerProvider).status == TermsStatusEnum.initial) {
        ref.read(termsControllerProvider.notifier).getLatestTerms();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);
    final prefs = ref.watch(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;

    final profileState =
        isFullyLoggedIn ? ref.watch(profileControllerProvider) : null;

    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    final drawerBg = isDark
        ? theme.colorScheme.primary
        : TemplateAColors.lightModeBackground;
    final contentColor = isDark ? Colors.white : theme.colorScheme.primary;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: drawerBg,
      elevation: 8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, ref, isFullyLoggedIn, secondary),
          Divider(height: 1, color: contentColor.withValues(alpha: 0.12)),
          if (isFullyLoggedIn)
            _buildUserTile(context, profileState, contentColor),
          _buildSection(
            context: context,
            icon: Icons.settings,
            title: 'account_settings_contact'.tr,
            isExpanded: _helpExpanded,
            canExpand: true,
            contentColor: contentColor,
            onToggle: () => setState(() => _helpExpanded = !_helpExpanded),
            children: [
              _buildSubItem(
                context: context,
                iconImage: Images.languageIcon,
                title: 'language'.tr,
                contentColor: contentColor,
                onTap: () => _switchToProfileTabThenPush(
                  context, ref, 'profile_user_settings_language'),
              ),
              if (isFullyLoggedIn)
                _buildSubItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'notifications'.tr,
                  contentColor: contentColor,
                  onTap: () => _switchToProfileTabThenPush(
                    context, ref, 'profile_user_settings_notifications'),
                ),
              _buildSubItem(
                context: context,
                iconImage: Images.servicesIcon,
                title: 'app_theme'.tr,
                contentColor: contentColor,
                onTap: () => _switchToProfileTabThenPush(
                  context, ref, 'profile_user_settings_theme'),
              ),
              _buildLegalSubSection(context, contentColor),
            ],
          ),
          if (isFullyLoggedIn)
            _buildProfileSettingsSection(context, ref, contentColor),
        ],
      ),
    );
  }


  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isFullyLoggedIn,
    Color secondary,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final closeColor = isDark ? Colors.white : theme.colorScheme.primary;

    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: statusBarHeight + 10.h, bottom: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            button: true,
            label: 'close_drawer'.tr,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ExcludeSemantics(
                child: Icon(Icons.close, size: 24.sp, color: closeColor),
              ),
            ),
          ),
          if (isFullyLoggedIn)
            Semantics(
              button: true,
              label: 'dashboard_logout'.tr,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _showLogoutDialog(context, ref);
                },
                child: ExcludeSemantics(
                  child: CommonText(
                    titleText: 'dashboard_logout'.tr,
                    textStyle: TextStyle(
                      color: secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            )
          else
            Semantics(
              button: true,
              label: 'register'.tr,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToRegister(context, ref);
                },
                child: ExcludeSemantics(
                  child: CommonText(
                    titleText: 'register'.tr,
                    textStyle: TextStyle(
                      color: secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(
      BuildContext context, dynamic profileState, Color contentColor) {
    final name = profileState != null
        ? '${profileState.firstName} ${profileState.lastName}'.trim()
        : '';
    final email = profileState?.email ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: contentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
            child: Icon(
              Icons.person,
              size: 24.sp,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  CommonText(
                    titleText: name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: contentColor,
                    ),
                  ),
                SizedBox(height: 4.h),
                if (email.isNotEmpty)
                  CommonText(
                    titleText: email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      fontSize: 18.sp,
                      color: contentColor.withValues(alpha: 0.6),
                    ),
                  )
                else
                  ShimmerWidget(
                    child: Container(
                      height: 14.h,
                      width: 160.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettingsSection(
      BuildContext context, WidgetRef ref, Color contentColor) {
    final errorColor = Theme.of(context).colorScheme.error;
    return _buildSection(
      context: context,
      iconImage: Images.accountIcon,
      title: 'profile'.tr,
      isExpanded: _profileExpanded,
      canExpand: true,
      contentColor: contentColor,
      onToggle: () =>
          setState(() => _profileExpanded = !_profileExpanded),
      children: [
        _buildSubItem(
          context: context,
          icon: Icons.edit_outlined,
          title: 'account_my_profile'.tr,
          contentColor: contentColor,
          onTap: () => _switchToProfileTabThenPush(
            context, ref, 'profile_user_profile_edit'),
        ),
        _buildSubItem(
          context: context,
          icon: Icons.password,
          title: 'reset_password'.tr,
          contentColor: contentColor,
          onTap: () => _switchToProfileTabThenPush(
            context, ref, 'profile_user_settings_reset_password'),
        ),
        _buildSubItem(
          context: context,
          icon: Icons.delete_outline,
          title: 'delete_account'.tr,
          contentColor: contentColor,
          iconColor: errorColor,
          textColor: errorColor,
          onTap: () {
            Navigator.of(context).pop();
            _showDeleteAccountDialog(context, ref);
          },
        ),
      ],
    );
  }

  Widget _buildLegalSubSection(BuildContext context, Color contentColor) {
    final legalState = ref.watch(termsControllerProvider);
    return Column(
      children: [
        Semantics(
          button: true,
          label: 'legal'.tr,
          hint: _legalExpanded ? 'collapse'.tr : 'expand'.tr,
          child: InkWell(
          onTap: () => setState(() => _legalExpanded = !_legalExpanded),
          child: Padding(
            padding: EdgeInsets.only(left: 72.w, right: 20.w, top: 13.h, bottom: 13.h),
            child: ExcludeSemantics(child: Row(
              children: [
                CommonImage(
                  imagePath: Images.imprintIcon,
                  width: 18.w,
                  height: 18.w,
                  color: contentColor.withValues(alpha: 0.75),
                  label: 'legal_icon_label'.tr,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CommonText(
                    titleText: 'legal'.tr,
                    textStyle: TextStyle(
                      fontSize: 18.sp,
                      color: contentColor,
                    ),
                  ),
                ),
                Icon(
                  _legalExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18.sp,
                  color: contentColor.withValues(alpha: 0.7),
                ),
              ],
            )),
          ),
          ),
        ),
        if (_legalExpanded) ...[
          _buildDeepSubItem(
            context: context,
            icon: Icons.accessibility_new_outlined,
            title: 'accessibility'.tr,
            contentColor: contentColor,
            onTap: () {
              Navigator.of(context).pop();
              context.pushNamed(
                RouteConstant.webView.name,
                extra: CommonWebViewWidgetParams(
                  url: 'https://example.com/accessibility',
                  title: 'accessibility'.tr,
                  showCloseButton: true,
                  appBarHeight: 64,
                ),
              );
            },
          ),
          if (legalState.privacyUrl.isNotEmpty)
            _buildDeepSubItem(
              context: context,
              iconImage: Images.privacyIcon,
              title: 'privacy_policy'.tr,
              contentColor: contentColor,
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(
                  RouteConstant.webView.name,
                  extra: CommonWebViewWidgetParams(
                    url: legalState.privacyUrl,
                    title: 'privacy_policy'.tr,
                    showCloseButton: true,
                    appBarHeight: 64,
                  ),
                );
              },
            ),
          if (legalState.imprintUrl.isNotEmpty)
            _buildDeepSubItem(
              context: context,
              iconImage: Images.imprintIcon,
              title: 'imprint'.tr,
              contentColor: contentColor,
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(
                  RouteConstant.webView.name,
                  extra: CommonWebViewWidgetParams(
                    url: legalState.imprintUrl,
                    title: 'imprint'.tr,
                    showCloseButton: true,
                    appBarHeight: 64,
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildDeepSubItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    required Color contentColor,
    IconData? icon,
    String? iconImage,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 96.w, right: 20.w, top: 12.h, bottom: 12.h),
        child: ExcludeSemantics(child: Row(
          children: [
            if (iconImage != null)
              CommonImage(
                imagePath: iconImage,
                width: 20.w,
                height: 20.w,
                color: contentColor.withValues(alpha: 0.75),
                label: title,
              )
            else if (icon != null)
              Icon(icon, size: 22.sp, color: contentColor.withValues(alpha: 0.75)),
            SizedBox(width: 10.w),
            Expanded(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(fontSize: 18.sp, color: contentColor),
              ),
            ),
          ],
        )),
      ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required bool isExpanded,
    required bool canExpand,
    required List<Widget> children,
    required Color contentColor,
    IconData? icon,
    String? iconImage,
    VoidCallback? onToggle,
  }) {
    return Column(
      children: [
        Semantics(
          button: canExpand,
          label: title,
          hint: canExpand ? (isExpanded ? 'collapse'.tr : 'expand'.tr) : null,
          child: InkWell(
          onTap: canExpand ? onToggle : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: ExcludeSemantics(child: Row(
              children: [
                if (iconImage != null)
                  CommonImage(
                    imagePath: iconImage,
                    width: 24.w,
                    height: 24.w,
                    color: contentColor,
                    label: title,
                  )
                else if (icon != null)
                  Icon(icon, size: 24.sp, color: contentColor),
                SizedBox(width: 14.w),
                Expanded(
                  child: CommonText(
                    titleText: title,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      color: contentColor,
                    ),
                  ),
                ),
                if (canExpand)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20.sp,
                    color: contentColor.withValues(alpha: 0.7),
                  ),
              ],
            )),
          ),
          ),
        ),
        if (isExpanded && children.isNotEmpty) ...children,
        Divider(
            height: 1, color: contentColor.withValues(alpha: 0.10)),
      ],
    );
  }

  Widget _buildSubItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    required Color contentColor,
    IconData? icon,
    String? iconImage,
    Color? iconColor,
    Color? textColor,
  }) {
    final resolvedIconColor = iconColor ?? contentColor.withValues(alpha: 0.75);
    final resolvedTextColor = textColor ?? contentColor;

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: 72.w, right: 20.w, top: 13.h, bottom: 13.h),
        child: ExcludeSemantics(child: Row(
          children: [
            if (iconImage != null)
              CommonImage(
                imagePath: iconImage,
                width: 20.w,
                height: 20.w,
                color: resolvedIconColor,
                label: title,
              )
            else if (icon != null)
              Icon(icon, size: 20.sp, color: resolvedIconColor),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  color: resolvedTextColor,
                ),
              ),
            ),
          ],
        )),
      ),
      ),
    );
  }

  void _switchToProfileTabThenPush(BuildContext context, WidgetRef ref, String routeName) {
    final router = GoRouter.of(context);
    final tabs = ref.read(shellConfigProvider) ?? [];
    final profileIndex = tabs.indexWhere((t) => t.action?.target == 'profile');
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileIndex != -1) {
        widget.navigationShell.goBranch(profileIndex);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          router.pushNamed(routeName);
        } catch (_) {
          final fallback = _fallbackScreenForRoute(routeName);
          if (fallback != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => fallback),
            );
          }
        }
      });
    });
  }

  Widget? _fallbackScreenForRoute(String routeName) {
    if (routeName.endsWith('user_profile_edit')) return const ProfileEditScreen();
    if (routeName.endsWith('user_settings_language')) return const SelectLanguageScreen();
    if (routeName.endsWith('user_settings_theme')) return const SelectThemeScreen();
    if (routeName.endsWith('user_settings_reset_password')) return const ResetPasswordScreen();
    if (routeName.endsWith('user_settings_notifications')) return const NotificationPrefsScreen();
    return null;
  }

  void _navigateToRegister(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).clearGuestSession();
    if (context.mounted) context.goNamed(RouteConstant.onboarding.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider.notifier).onPageChanged(2);
    });
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final accountController = ref.read(accountControllerProvider.notifier);
    final router = GoRouter.of(context);
    final theme = Theme.of(context);
    final bgColor = theme.extension<AppContainerColors>()!.inverse;
    final secondaryColor = theme.colorScheme.secondary;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: CommonText(
          titleText: 'dashboard_logout'.tr,
          textAlign: TextAlign.center,
          textStyle:
              TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
        ),
        content: CommonText(titleText: 'logout_confirmation_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: CommonText(
              titleText: 'cancel'.tr,
              textStyle: TextStyle(color: secondaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await accountController.logout();
              router.goNamed(RouteConstant.onboarding.name);
            },
            child: CommonText(
              titleText: 'dashboard_logout'.tr,
              textStyle: TextStyle(color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final router = GoRouter.of(context);
    final bgColor = theme.extension<AppContainerColors>()!.inverse;
    final secondaryColor = theme.colorScheme.secondary;
    final errorColor = theme.colorScheme.error;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: CommonText(
          titleText: 'delete_account_confirmation'.tr,
          textAlign: TextAlign.center,
          textStyle:
              TextStyle(fontSize: 24.sp, fontWeight: FontWeight.normal),
        ),
        content: CommonText(titleText: 'delete_account_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: CommonText(
              titleText: 'cancel'.tr,
              textStyle: TextStyle(color: secondaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final deleted = await ref
                  .read(profileControllerProvider.notifier)
                  .deleteAccount();
              if (deleted && dialogCtx.mounted) {
                router.goNamed(RouteConstant.onboarding.name);
              }
            },
            child: CommonText(
              titleText: 'delete'.tr,
              textStyle: TextStyle(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
