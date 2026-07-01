import 'dart:developer' as dev;

abstract class AnalyticsService {
  Future<void> logScreenView(String screenName);
  Future<void> logScreenEnd(String screenName);
  Future<void> logEvent(String eventName, {Map<String, dynamic>? params});
}

class AnalyticsServiceImpl implements AnalyticsService {
  const AnalyticsServiceImpl();

  @override
  Future<void> logScreenView(String screenName) async {
    dev.log('📲 screen_view: $screenName', name: 'Analytics');
    // ignore: avoid_print
    print('[Analytics] screen_view: $screenName');
  }

  @override
  Future<void> logScreenEnd(String screenName) async {
    dev.log('📴 screen_end: $screenName', name: 'Analytics');
    // ignore: avoid_print
    print('[Analytics] screen_end: $screenName');
  }

  @override
  Future<void> logEvent(String eventName,
      {Map<String, dynamic>? params}) async {
    dev.log(
      '🎯 event: $eventName${params != null ? ' | params: $params' : ''}',
      name: 'Analytics',
    );
    // ignore: avoid_print
    print(
        '[Analytics] event: $eventName${params != null ? ' | params: $params' : ''}');
  }
}
