part of routing;


var routingControllerProvider =
    NotifierProvider<RoutingController, List<GoRoute>>(
        () => RoutingController());

var refreshStreamProvider = Provider((ref) {
  return ref.read(routingControllerProvider.notifier).refreshStream;
});

/// The signature of the page builder callback for a matched GoRoute.
typedef PageBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

/// The signature of the redirect builder callback for a matched GoRoute.
typedef RedirectBuilder = String? Function(
  GoRouterState state,
);

/// Helper method to generate GoRoutes without using constructor
GoRoute generateRoute(
    {required String path,
    required String name,
    required PageBuilder pageBuilder,
    List<GoRoute>? subRoutes}) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        MaterialPage(key: state.pageKey, child: pageBuilder(context, state)),
    routes: subRoutes ?? const [],
  );
}

class RoutingController extends Notifier<List<GoRoute>> {

  @override
  List<GoRoute> build() {
    refreshStream = controller.stream;
    return [];
  }

  // RoutingController()  {
  //   refreshStream = controller.stream;
  // }

  List<RedirectBuilder> redirectConditions = List.empty(growable: true);
  StreamController controller = StreamController();
  Stream? refreshStream;

  void addRoute(GoRoute route) {
    state.add(route);
  }

  void addRoutes(List<GoRoute> routes) {
    state.addAll(routes);
  }

  void addRedirectCondition(RedirectBuilder redirectBuilder) {
    redirectConditions.add((state) => redirectBuilder(state));
  }

  void addRedirectConditions(List<RedirectBuilder> redirects) {
    for (var redirect in redirects) {
      redirectConditions.add((state) => redirect(state));
    }
  }

  void refreshRouter() {
    controller.add(null);
  }


}
