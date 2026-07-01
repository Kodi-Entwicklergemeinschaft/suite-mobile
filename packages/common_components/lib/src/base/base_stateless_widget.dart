import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../analytics/analytics_provider.dart';

abstract class BaseStatelessWidget extends ConsumerWidget {
  const BaseStatelessWidget({Key? key}) : super(key: key);

  /// Optional screen name for analytics tracking (e.g. `'home_screen'`).
  /// Override in full-screen route widgets to enable automatic screen tracking.
  String? get screenName => null;

  /// Sends a named event to the analytics service.
  void trackEvent(WidgetRef ref, String eventName,
      {Map<String, dynamic>? params}) {
    ref.read(analyticsServiceProvider).logEvent(eventName, params: params);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref);
}
