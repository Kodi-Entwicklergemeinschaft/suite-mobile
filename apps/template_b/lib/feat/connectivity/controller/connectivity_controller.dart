import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/connectivity/constant/connectivity_constant.dart';
import 'package:template_b/feat/connectivity/state/connectivity_state.dart';

final connnectivityControllerProvider =
    NotifierProvider<ConnectivityController, ConnectivityState>(
      () => ConnectivityController(),
    );

class ConnectivityController extends Notifier<ConnectivityState> {
  @override
  ConnectivityState build() {
    Future.microtask(() => _init());
    return ConnectivityState(ConnectivityConstant.loading);
  }

  Future<void> _init() async {
    _updateFromResult(await Connectivity().checkConnectivity());
    Connectivity().onConnectivityChanged.listen(_updateFromResult);
  }

  void _updateFromResult(List<ConnectivityResult> result) {
    final isDisconnected = result.contains(ConnectivityResult.none);
    final next = isDisconnected
        ? ConnectivityConstant.isDisconnected
        : ConnectivityConstant.isConnected;
    state = state.copyWith(connectivityConstant: next);
  }

  Future<void> checkConnectivity() async {
    _updateFromResult(await Connectivity().checkConnectivity());
  }
}
