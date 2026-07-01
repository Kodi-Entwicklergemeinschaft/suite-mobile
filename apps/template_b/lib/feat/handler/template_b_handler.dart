import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/core/constants/action_constant.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:common_components/src/handler/feature_handler.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:template_b/feat/handler/service_hub_handler.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:template_b/feat/linkhub_service/data/model/linkhub_service_model.dart';
import 'package:template_b/feat/linkhub_service/routes/linkhub_service_routes.dart';

final templateBHandlerProvider = Provider(
  (ref) => TemplateBHandler(
    ref: ref,
    featureHandler: ref.read(featureHandlerProvider),
    serviceHubHandler: ref.read(serviceHubHandlerProvider),
    webViewHandler: ref.read(webViewHandlerProvider),
    launcherHandler: ref.read(launcherHandler),
  ),
);

class TemplateBHandler implements ActionHandler<ActionResponseModel> {
  final Ref ref;
  FeatureHandler featureHandler;
  WebViewHandler webViewHandler;
  ServiceHubHandler serviceHubHandler;
  LauncherHandler launcherHandler;

  TemplateBHandler({
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
  }) async {
    // Auth guard — if action requires login and user is not logged in, show login sheet
    if (data.config?.requireLogin == true) {
      final isLoggedIn = ref.read(authStateProvider);
      if (!isLoggedIn) {
        await CommonSheet.show(
          context,
          title: 'sign_in'.tr,
          content: 'please_login_to_continue'.tr,
          confirmButtonText: 'sign_in'.tr,
          cancelButtonText: 'cancel'.tr,
          onConfirm: () {
            if (context.mounted) {
              context.pushNamed(AppRouteConstants.signIn.name);
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
              url: data.config!.url!,
              title: title ?? '',
              requiredShortCode: data.config?.requiredShortCode ?? false,
            ),
          );
        }
        break;
      case ActionConstant.feature || ActionConstant.category:
        final slug = data.target;
        if (slug == null) {
          debugPrint('executeAction: could not resolve feature slug, skipping');
          break;
        }
        final config = <String, dynamic>{
          ...?data.config?.toJson(),
          if (data.tenantServiceId != null)
            'tenantServiceId': data.tenantServiceId,
          if (data.localityId != null) 'localityId': data.localityId,
        };
        featureHandler.executeAction(
          context,
          FeatureHandlerParams(
            featureSlug: slug,
            config: config.isNotEmpty ? config : null,
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
      case ActionConstant.linkHub:
        if (context.mounted) {
          context.pushNamed(
            LinkhubServiceRoutes.screen.name,
            extra: LinkhubServiceModel.fromAction(
              id: data.tenantServiceId ?? data.target ?? '',
              title: title ?? '',
              image: data.serviceImage,
              config: data.config,
              variant: data.variant,
            ),
          );
        }
        break;
      default:
        debugPrint('Unknown action type: $type');
    }
  }
}
