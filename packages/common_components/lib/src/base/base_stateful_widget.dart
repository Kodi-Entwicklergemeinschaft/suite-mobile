import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../analytics/analytics_provider.dart';
import '../analytics/analytics_service.dart';

abstract class BaseStatefulWidget extends ConsumerStatefulWidget {
  const BaseStatefulWidget({Key? key}) : super(key: key);

  /// Optional screen name for analytics tracking (e.g. `'home_screen'`).
  /// Override in full-screen route widgets to enable automatic screen tracking.
  String? get screenName => null;
}

abstract class BaseStatefulWidgetState<T extends BaseStatefulWidget>
    extends ConsumerState<T> {
  late AnalyticsService _analytics;

  /// Called once after the first frame. Override to add custom screen-view logic.
  @protected
  void onScreenView() {
    final name = widget.screenName;
    if (name != null) _analytics.logScreenView(name);
  }

  /// Called at the start of [dispose]. Override to add custom session-end logic.
  @protected
  void onScreenDispose() {
    final name = widget.screenName;
    if (name != null) _analytics.logScreenEnd(name);
  }

  /// Sends a named event to the analytics service.
  void trackEvent(String eventName, {Map<String, dynamic>? params}) {
    _analytics.logEvent(eventName, params: params);
  }

  @override
  void initState() {
    super.initState();
    _analytics = ref.read(analyticsServiceProvider);
    if (widget.screenName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onScreenView();
      });
    }
  }

  @override
  void dispose() {
    onScreenDispose();
    super.dispose();
  }
}
