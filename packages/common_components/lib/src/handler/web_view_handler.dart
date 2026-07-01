import 'package:flutter/src/widgets/framework.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:common_components/src/widgets/common_web_view_widget/common_web_view_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final webViewHandlerProvider = Provider((ref) => WebViewHandler());

class WebViewHandler implements ActionHandler<CommonWebViewWidgetParams> {
  @override
  void executeAction(BuildContext context, data, {String? title}) {
    context.pushNamed(AppRouteConstants.commonWebView.name, extra: data);
  }
}
