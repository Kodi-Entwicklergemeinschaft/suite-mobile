import 'package:flutter/src/widgets/framework.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final featureHandlerProvider = Provider((ref) => FeatureHandler());

class FeatureHandler implements ActionHandler<FeatureHandlerParams> {
  @override
  void executeAction(
    BuildContext context,
    FeatureHandlerParams data, {
    String? title,
  }) {
    // Generic navigation: if config exists, pass it via route extra
    if (data.config != null) {
      // Add title to config if provided
      final configWithTitle = title != null
          ? {...data.config!, 'title': title}
          : data.config;
      context.pushNamed(data.featureSlug, extra: configWithTitle);
    } else {
      context.pushNamed(data.featureSlug);
    }
  }
}

class FeatureHandlerParams {
  final String featureSlug;
  final Map<String, dynamic>? config;

  FeatureHandlerParams({required this.featureSlug, this.config});
}
