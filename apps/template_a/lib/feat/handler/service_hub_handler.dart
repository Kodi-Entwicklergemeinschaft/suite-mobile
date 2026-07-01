import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/feat/sub_service/presentation/sub_service_screen.dart';

final serviceHubHandlerProvider = Provider((ref) => ServiceHubHandler());

class ServiceHubHandler implements ActionHandler<ActionResponseModel> {
  @override
  void executeAction(BuildContext context, data, {String? title}) {
    final location = GoRouterState.of(context).matchedLocation;
    final slugMatch = RegExp(r'^/shell/([^/]+)').firstMatch(location);
    final tabSlug = slugMatch?.group(1) ?? '';

    context.pushNamed(
      '${tabSlug}_sub_service',
      extra: SubServiceScreenParams(
        title: title ?? '',
        services: data.config?.children ?? [],
        tabSlug: tabSlug,
      ),
    );
  }
}
