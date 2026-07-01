import 'package:flutter/src/widgets/framework.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/model/action_response_model.dart';
import 'package:template_c/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_c/router/route_constant.dart';

final serviceHubHandlerProvider = Provider((ref) => ServiceHubHandler());

class ServiceHubHandler implements ActionHandler<ActionResponseModel> {
  @override
  void executeAction(BuildContext context, data, {String? title}) {
    context.pushNamed(
      RouteConstant.subService.name,
      extra: SubServiceScreenParams(
        title: title ?? '',
        services: data.config?.children ?? [],
      ),
    );
  }
}
