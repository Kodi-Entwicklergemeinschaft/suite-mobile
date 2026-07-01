import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';
import 'package:template_b/routes/app_routes.dart';
import '../../controller/profile_controller.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/profile_logout_listener.dart';
import '../widgets/menu_item_widget.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:theme/theme.dart';

class MyProfileScreen extends BaseStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  String get screenName => AppRouteConstants.myProfile.name;

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends BaseStatefulWidgetState<MyProfileScreen> {
  void _showLogoutConfirmDialog(BuildContext context) {
    CommonSheet.showConfirmation(
      context,
      title: 'sign_out'.tr,
      content: 'logout_confirm'.tr,
      confirmButtonText: 'sign_out'.tr,
      cancelButtonText: 'cancel'.tr,
      onConfirm: () {
        ref.read(profileControllerProvider.notifier).logout();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoggedIn = ref.watch(authStateProvider);
    final homeState = ref.watch(homeProvider);

    return LogoutListener(
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'my_profile'.tr,
          centerTitle: true,
          showBackButton: false,
          actions: [
            Center(
              child: Semantics(
                button: true,
                label: isLoggedIn ? 'sign_out'.tr : 'sign_in'.tr,
                child: GestureDetector(
                  onTap: () {
                    if (isLoggedIn) {
                      _showLogoutConfirmDialog(context);
                    } else {
                      context.pushNamed(AppRouteConstants.signIn.name);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: ExcludeSemantics(
                      child: Text(
                        isLoggedIn ? 'sign_out'.tr : 'sign_in'.tr,
                        style: TextStyle(
                          color: ref
                              .watch(appThemeProvider)
                              .colors
                              .surfaceLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(profileControllerProvider.notifier).getProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Show profile card only if logged in
                if (isLoggedIn && profileState.data != null)
                  ProfileCardWidget(
                    image: profileState.data?.avatarUrl,
                    username: profileState.data?.username,
                    email: profileState.data?.email,
                    onTap: () =>
                        context.pushNamed(AppRouteConstants.editProfile.name),
                  ),

                MenuItemWidget(
                  title: 'settings'.tr,
                  onTap: () =>
                      context.pushNamed(AppRouteConstants.settings.name),
                ),
                if (isLoggedIn) ...[
                  MenuItemWidget(
                    title: 'dashboard'.tr,
                    onTap: () {
                      context.pushNamed(AppRouteConstants.dashboardScreen.name);
                    },
                  ),
                  MenuItemWidget(
                    title: 'feedback'.tr,
                    onTap: () {
                      context.pushNamed(AppRouteConstants.feedback.name);
                    },
                  ),
                  MenuItemWidget(
                    title: 'contact_us'.tr,
                    onTap: () {
                      context.pushNamed(AppRouteConstants.contact.name);
                    },
                  ),
                ],

                if (homeState.faqData?.action?.config?.url?.isNotEmpty == true)
                  MenuItemWidget(
                    title: homeState.faqData?.title ?? 'faq'.tr,
                    onTap: () {
                      final faqUrl = homeState.faqData?.action?.config?.url;
                      if (faqUrl != null && faqUrl.isNotEmpty) {
                        ref
                            .read(webViewHandlerProvider)
                            .executeAction(
                              context,
                              CommonWebViewWidgetParams(
                                url: faqUrl,
                                title: homeState.faqData?.title ?? 'faq'.tr,
                              ),
                            );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
