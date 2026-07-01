import 'package:template_b/feat/connectivity/constant/connectivity_constant.dart';

class ConnectivityState {
  ConnectivityConstant connectivityConstant;

  ConnectivityState(this.connectivityConstant);

  ConnectivityState copyWith({ConnectivityConstant? connectivityConstant}) {
    return ConnectivityState(connectivityConstant ?? this.connectivityConstant);
  }
}
