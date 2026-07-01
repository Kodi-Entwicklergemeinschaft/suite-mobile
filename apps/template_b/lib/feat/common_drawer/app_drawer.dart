import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:common_components/src/handler/web_view_handler.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';
import 'package:template_b/feat/profile/controller/profile_controller.dart';
import 'package:template_b/routes/app_routes.dart';

import 'common_drawer.dart';

/// Builds the app drawer once. Use this wherever a drawer is needed (e.g. home, services).
Widget buildAppDrawer(BuildContext context, WidgetRef ref) {
  final isLoggedIn = ref.watch(authStateProvider);
  final homeState = ref.watch(homeProvider);

  return CommonDrawer(
    title: 'Menu Bar',
    logoutLabel: 'logout'.tr,
    items: [
      CommonDrawerItem(
        title: 'my_profile'.tr,
        onTap: () => context.pushNamed(AppRouteConstants.myProfile.name),
      ),
      CommonDrawerItem(
        title: 'settings'.tr,
        onTap: () => context.pushNamed(AppRouteConstants.settings.name),
      ),
      if (homeState.faqData?.action?.config?.url?.isNotEmpty == true)
        CommonDrawerItem(
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
      if (isLoggedIn)
        CommonDrawerItem(
          title: 'contact_us'.tr,
          onTap: () => context.pushNamed(AppRouteConstants.contact.name),
        ),
    ],
    onLogout: isLoggedIn ? () => _handleLogout(context, ref) : null,
  );
}

void _handleLogout(BuildContext context, WidgetRef ref) {
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
