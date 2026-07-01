import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/feature_handler.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/action_constant.dart';
import 'package:template_c/core/model/action_response_model.dart';
import 'package:template_c/core/providers/auth_state_provider.dart';
import 'package:template_c/feat/handler/service_hub_handler.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/params/listing_screen_params.dart';
import 'package:template_c/router/route_constant.dart';

final templateCHandlerProvider = Provider(
  (ref) => TemplateCHandler(
    ref: ref,
    featureHandler: ref.read(featureHandlerProvider),
    serviceHubHandler: ref.read(serviceHubHandlerProvider),
    webViewHandler: ref.read(webViewHandlerProvider),
    launcherHandler: ref.read(launcherHandler),
  ),
);

class TemplateCHandler implements ActionHandler<ActionResponseModel> {
  final Ref ref;
  FeatureHandler featureHandler;
  WebViewHandler webViewHandler;
  ServiceHubHandler serviceHubHandler;
  LauncherHandler launcherHandler;

  TemplateCHandler({
    required this.ref,
    required this.featureHandler,
    required this.serviceHubHandler,
    required this.webViewHandler,
    required this.launcherHandler,
  });

  @override
  Future<void> executeAction(
    BuildContext context,
    data, {
    String? title,
    ListingFilterModel? filter,
    String? familyKey,
  }) async {
    // Auth guard — if action requires login and user is not logged in, show login sheet
    if (data.config?.requireLogin == true) {
      final isLoggedIn = ref.read(authStateProvider);
      if (!isLoggedIn) {
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
    }

    final type = ActionConstant.fromName(data.type);

    switch (type) {
      case ActionConstant.serviceHub:
        serviceHubHandler.executeAction(context, data, title: title);
        break;
      case ActionConstant.urlWebview:
        if (data.config?.url != null && data.config!.url!.isNotEmpty) {
          webViewHandler.executeAction(
            context,
            CommonWebViewWidgetParams(
              backgroundColor: Theme.of(context).colorScheme.primary,
              url: data.config!.url!,
              title: title ?? '',
              requiredShortCode: data.config?.requiredShortCode ?? false,
            ),
          );
        }
        break;
      case ActionConstant.category:
        final screenTitle = title ?? '';
        final listingFilter = filter ?? ListingFilterModel(page: 1);
        final resolvedFamilyKey =
            familyKey ??
            listingFilter.subcategorySlug ??
            listingFilter.categorySlug ??
            '';
        final params = ListingScreenParams(
          familyKey: ListingFamilyKey.seeAll(resolvedFamilyKey),
          screenTitle: screenTitle,
          initialFilter: listingFilter.copyWith(limit: 20),
        );
        context.pushNamed(RouteConstant.listingScreen.name, extra: params);
        break;
      case ActionConstant.feature:
        featureHandler.executeAction(
          context,
          FeatureHandlerParams(
            featureSlug: data.target!,
            config: data.config?.toJson(),
          ),
          title: title,
        );
        break;
      case ActionConstant.urlBrowser:
        debugPrint(
          'SHORT CODE NEED = ${data.config?.requiredShortCode ?? false}',
        );

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
}
