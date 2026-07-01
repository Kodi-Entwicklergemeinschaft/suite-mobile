import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:common_components/common_components.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/action_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/handler/service_hub_handler.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;
import 'package:theme/theme.dart';

final templateAHandlerProvider = Provider(
  (ref) => TemplateAHandler(
    ref: ref,
    featureHandler: ref.read(featureHandlerProvider),
    serviceHubHandler: ref.read(serviceHubHandlerProvider),
    launcherHandler: ref.read(launcherHandler),
  ),
);

class TemplateAHandler implements ActionHandler<ActionResponseModel> {
  final Ref ref;
  FeatureHandler featureHandler;
  ServiceHubHandler serviceHubHandler;
  LauncherHandler launcherHandler;

  TemplateAHandler({
    required this.ref,
    required this.featureHandler,
    required this.serviceHubHandler,
    required this.launcherHandler,
  });

  @override
  Future<void> executeAction(BuildContext context, data, {String? title, String? tabSlug}) async {
    // Auth guard
    final requireLogin = data.config?.requireLogin == true;
    final isGuestOnly = data.config?.isGuestOnly == true;
    final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);

    if (requireLogin && !isGuestOnly && isGuest) {
      // logged-in only → prompt guest to sign in
      await CommonSheet.showConfirmation(
        context,
        title: 'sign_in'.tr,
        content: 'please_login_to_continue'.tr,
        confirmButtonText: 'sign_in'.tr,
        cancelButtonText: 'cancel'.tr,
        onConfirm: () {
          if (context.mounted) {
            context.pushNamed(RouteConstant.signin.name);
          }
        },
      );
      return;
    }

    if (isGuestOnly && !requireLogin && !isGuest) {
      // guest only → block for real logged-in users
      return;
    }

    final type = ActionConstant.fromName(data.type);

    switch (type) {
      case ActionConstant.serviceHub:
        serviceHubHandler.executeAction(context, data, title: title);
        break;
      case ActionConstant.category:
        if (data.config?.isDialogue == true &&
            data.config?.dialogueContent != null) {
          await _showDialogThenNavigate(context, data, title: title, tabSlug: tabSlug);
        } else {
          _navigateToCategory(context, data, title: title, tabSlug: tabSlug);
        }
        break;
      case ActionConstant.feature:
        final target = data.target ?? '';
        final tabs = ref.read(shellConfigProvider);
        final matchingTab = tabs?.where((t) => t.action?.target == target).firstOrNull;
        if (matchingTab != null) {
          context.go('/shell/${matchingTab.slug}');
        } else {
          try {
            featureHandler.executeAction(
              context,
              FeatureHandlerParams(
                featureSlug: target,
                config: data.config?.toJson(),
              ),
              title: title,
            );
          } catch (e) {
            debugPrint('[TemplateAHandler] Unknown feature target: $target — $e');
            if (context.mounted) {
              await CommonSheet.showConfirmation(
                context,
                title: title ?? '',
                content: 'coming_soon'.tr,
                confirmButtonText: 'ok'.tr,
                cancelButtonText: '',
                onConfirm: () {},
              );
            }
          }
        }
        break;
      case ActionConstant.urlWebview:
        if (data.config?.url != null && data.config!.url!.isNotEmpty) {
          context.pushNamed(
            RouteConstant.webView.name,
            extra: CommonWebViewWidgetParams(
              url: data.config!.url!,
              title: title ?? '',
              requiredShortCode: data.config?.requiredShortCode ?? false,
              showCloseButton: true,
              appBarHeight: 64,
            ),
          );
        }
        break;
      case ActionConstant.urlBrowser:
        launcherHandler.executeAction(
          context,
          data.config!.url!,
          shortCodeRequired: data.config?.requiredShortCode ?? false,
        );
        break;
      default:
        debugPrint('Unknown action type: $type');
    }
  }

  Future<void> _showDialogThenNavigate(
    BuildContext context,
    ActionResponseModel data, {
    String? title,
    String? tabSlug,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return Dialog(
          backgroundColor: theme.extension<AppContainerColors>()!.inverse,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 52.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CommonText(
                    titleText: data.config!.dialogueContent!,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      if (context.mounted) {
                        _navigateToCategory(context, data, title: title, tabSlug: tabSlug);
                      }
                    },
                    child: CommonText(
                      titleText: 'ok'.tr,
                      textStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToCategory(
    BuildContext context,
    ActionResponseModel data, {
    String? title,
    String? tabSlug,
  }) {
    final location = GoRouterState.of(context).matchedLocation;
    final shellMatch = RegExp(r'^/shell/([^/]+)').firstMatch(location);
    final firstTabSlug = ref.read(shellConfigProvider)?.firstOrNull?.slug ?? '';
    final resolvedTabSlug = tabSlug ?? shellMatch?.group(1) ?? firstTabSlug;

    context.push(
      '/shell/$resolvedTabSlug/category',
      extra: CategoryScreenParams(
        categorySlug: data.config?.category ?? data.target ?? '',
        screenTitle: title ?? '',
        headerColorHex: null,
        showFilter: data.config?.isFilter,
      ),
    );
  }
}

