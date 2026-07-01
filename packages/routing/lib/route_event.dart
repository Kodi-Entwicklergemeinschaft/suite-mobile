part of routing;

enum AppRoutesType {
  verifyOtp,
  dashboard
}
final navigationEventProvider = Provider<RouteEvent?>((ref) => null);

class RouteEvent {
  String path;
  Object? extra;
  AppRoutesType appRoutesType;
  RouteEvent({required this.path, this.extra,required this.appRoutesType});
}
