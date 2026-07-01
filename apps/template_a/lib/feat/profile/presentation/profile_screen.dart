import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:common_components/common_components.dart';
import 'package:template_a/core/providers/auth_state_provider.dart';
import 'package:template_a/feat/onboarding/controller/onboarding_controller.dart';
import 'package:template_a/feat/auth/controllers/auth_controller.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/fav/controller/fav_controller.dart';
import 'package:template_a/feat/fav/data/model/response_model/fav_profile_category_model.dart';
import 'package:template_a/feat/fav/state/fav_state.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';
import 'package:template_a/feat/user/account/controller/account_controller.dart';
import 'package:template_a/feat/user/profile/presentation/profile_edit_screen.dart';
import 'package:template_a/feat/user/settings/presentation/settings_screen.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:theme/theme.dart';

class ProfileScreen extends BaseStatefulWidget {
  final String? tabSlug;
  const ProfileScreen({super.key, this.tabSlug});

  @override
  String? get screenName => tabSlug;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseStatefulWidgetState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);
    final prefs = ref.watch(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;
    final accountController = ref.read(accountControllerProvider.notifier);

    if (isFullyLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final favState = ref.read(favScreenControllerProvider);
        if (!favState.hasLoadedProfileCategories &&
            !favState.isProfileCategoriesLoading) {
          ref
              .read(favScreenControllerProvider.notifier)
              .getProfileFavCategories();
        }
      });
    }

    final favState =
        isFullyLoggedIn ? ref.watch(favScreenControllerProvider) : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                CommonText(
                  titleText: 'account_header'.tr,
                  textStyle: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 12.h),
                _buildAccountMenuItems(
                    context, isFullyLoggedIn, accountController),
                SizedBox(height: 24.h),
                if (isFullyLoggedIn) _buildFavoritesSection(context, favState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountMenuItems(
    BuildContext context,
    bool isFullyLoggedIn,
    AccountController controller,
  ) {
    return Column(
      spacing: 12.h,
      children: [
        if (isFullyLoggedIn)
          _buildMenuItem(
            context: context,
            imagePath: Images.accountIcon,
            title: 'account_my_profile'.tr,
            onTap: () {
              try {
                context.pushNamed('profile_user_profile_edit');
              } catch (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              }
            },
          ),
        _buildMenuItem(
          context: context,
          icon: Icons.settings,
          title: 'account_settings_contact'.tr,
          onTap: () {
            try {
              context.pushNamed('profile_user_settings');
            } catch (_) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }
          },
        ),
        if (isFullyLoggedIn)
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            title: 'dashboard_logout'.tr,
            onTap: () => _showLogoutDialog(context, controller),
          ),
        if (!isFullyLoggedIn)
          _buildMenuItem(
            context: context,
            icon: Icons.login,
            title: 'register_login'.tr,
            onTap: () async {
              await ref.read(authControllerProvider.notifier).clearGuestSession();
              if (context.mounted) context.goNamed(RouteConstant.onboarding.name);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(onboardingControllerProvider.notifier).onPageChanged(3);
              });
            },
          ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    IconData? icon,
    String? imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
      onTap: onTap,
      enableFeedback: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.h),
        child: ExcludeSemantics(
          child: Row(
          children: [
            if (imagePath != null)
              CommonImage(
                imagePath: imagePath,
                height: 26.h,
                width: 26.h,
                fit: BoxFit.contain,
                color: Theme.of(context).iconTheme.color,
                label: title,
              )
            else if (icon != null)
              CommonIcon(
                icon: icon,
                size: 26.h,
                color: Theme.of(context).iconTheme.color,
                label: title,
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonText(
                titleText: title,
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            CommonImage(
              imagePath: Images.arrowAccountIcon,
              width: 12.sp,
              color: Theme.of(context).extension<AppTextColors>()!.normal,
            ),
          ],
        ),
        ),
      ),
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context, FavState? favState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          titleText: 'account_favorites_title'.tr,
          textStyle: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),
        _buildFavCategoriesContent(context, favState),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildFavCategoriesContent(BuildContext context, FavState? favState) {
    if (favState == null) return const SizedBox.shrink();

    if (favState.isProfileCategoriesLoading &&
        favState.profileFavCategories.isEmpty) {
      return SizedBox(
        height: 80.h,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }

    if (favState.profileFavCategories.isEmpty) {
      return SizedBox(
        height: 80.h,
        child: Center(child: CommonText(titleText: 'no_fav_listing'.tr)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favState.profileFavCategories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final cat = favState.profileFavCategories[index];
        final color = _parseCategoryColor(cat.titleBackgroundColor, context);
        return CommonImageTextCard(
          imageUrl: cat.image ?? '',
          title: cat.title ?? '',
          titleColor: color,
          fontSize: 18.sp,
          onTap: () => _navigateToFavCategory(context, cat),
        );
      },
    );
  }

  void _navigateToFavCategory(
      BuildContext context, FavProfileCategoryModel cat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          params: CategoryScreenParams(
            categorySlug: cat.slug ?? '',
            screenTitle: cat.title ?? '',
            fromFavorites: true,
            headerColorHex: cat.titleBackgroundColor,
          ),
        ),
      ),
    );
  }

  Color _parseCategoryColor(String? hex, BuildContext context) {
    if (hex == null || hex.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }
    try {
      final cleaned = hex.startsWith('#')
          ? hex.replaceFirst('#', '0xff')
          : hex.startsWith('0x') || hex.startsWith('0X')
              ? hex
              : '0xff$hex';
      return Color(int.parse(cleaned));
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  void _showLogoutDialog(
    BuildContext context,
    AccountController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor:
            Theme.of(context).extension<AppContainerColors>()!.inverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: CommonText(
          titleText: 'dashboard_logout'.tr,
          textAlign: TextAlign.center,
          textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
        ),
        content: CommonText(titleText: 'logout_confirmation_message'.tr),
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
              await controller.logout();
              if (context.mounted) {
                context.goNamed(RouteConstant.onboarding.name);
              }
            },
            child: CommonText(
              titleText: 'dashboard_logout'.tr,
              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
