part of routing;

class AppScreen {
  String name;
  String path;
  Page<dynamic> Function(BuildContext context, GoRouterState state) builder;

  AppScreen(this.name, this.path, this.builder);
}

class RouteUtils {
  late GoRouter _router;
  final List<GoRoute> _routes = [];
  late final FutureOr<String?> Function(
      BuildContext context, GoRouterState state)? _redirect;

  //Function(dynamic)? _callback;
  get router => _router;

  addRoutes(List<AppScreen> items,
      {FutureOr<String?> Function(BuildContext context, GoRouterState state)?
          redirect,
      FutureOr<bool> Function(BuildContext, GoRouterState)? onExit}) {
    if (_routes.isEmpty) {
      _routes.addAll(items
          .map<GoRoute>((e) => GoRoute(
                path: e.path,
                name: e.name,
                pageBuilder: (context, state) => e.builder(context, state),
              ))
          .toList());
      _redirect = redirect;
      initRouter();
    }
  }

  initRouter() {
    _router = GoRouter(
      ///Reference [https://github.com/csells/go_router/discussions/122#discussioncomment-1960950]
      //refreshListenable: GoRouterRefreshStream(refreshStream!),
      debugLogDiagnostics: true,
      routerNeglect: true,
      routes: _routes,
      redirect: _redirect,
      observers: [RouteObserver()],
      errorPageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: Center(child: Text(state.error.toString())),
      ),
    );
  }

  Future<T?> pushNamed<T>(String name,
      {Map<String, String> params = const <String, String>{},
      Map<String, dynamic> queryParams = const <String, dynamic>{},
      Object? extra,
      callback}) {
    //_callback = callback;
    debugPrint("Set callback SET: ${callback.hashCode}");
    //_callback?.call("chke");
    debugPrint("Set callback SET: ${callback.hashCode}");
    return _router.pushNamed(name,
        pathParameters: params, queryParameters: queryParams, extra: extra);
  }

  pushReplacedName<T>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    _router.pushReplacementNamed(name,
        pathParameters: params, queryParameters: queryParams, extra: extra);
  }

  pop(result) {
    debugPrint("pop: $result");

    //debugPrint("Set callback : ${_callback.hashCode}");
    //_callback?.call(result);
    //Navigator.popUntil(context, ModalRoute.withName('/notOnStack'));
    return _router.pop(result);
  }

  void popUntil(String name) {
    _router.goNamed(name);
  }

  void pushNamedAndRemoveUntil(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    while (_router.canPop()) {
      _router.pop();
    }
    _router.pushReplacementNamed(name,
        pathParameters: params, queryParameters: queryParams, extra: extra);
  }

  //in case require for web where path is consider for location
  _push(
    String path,
    Object? extra,
  ) {
    _router.push(path, extra: extra);
  }

  setCallback(Function(dynamic dynamic) callBack) {
    //_callback = callBack;
    //_callback!.call("chke");
    //debugPrint("Set callback : ${_callback.hashCode}");
  }
}

final routeUtilProvider = Provider((ref) {
  return RouteUtils();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  var routes = ref.watch(routingControllerProvider);
  var refreshStream = ref.read(refreshStreamProvider);
  return GoRouter(
    ///Reference [https://github.com/csells/go_router/discussions/122#discussioncomment-1960950]
    refreshListenable: GoRouterRefreshStream(refreshStream!),
    debugLogDiagnostics: true,
    routerNeglect: true,
    routes: routes,
    observers: [RouteObserver()],
    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: Center(child: Text(state.error.toString())),
    ),
    redirect: (context, state) {
      for (var value
          in ref.read(routingControllerProvider.notifier).redirectConditions) {
        var data = value(state);
        if (data != null) return data;
      }
      return null;
    },
  );
});
