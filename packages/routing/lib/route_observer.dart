import 'package:flutter/material.dart';

class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('RouteObserver: did push route');
  }


  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('RouteObserver: did pop route');
  }
}