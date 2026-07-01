import 'package:template_a/core/constant/state_constant.dart';
import '../../data/models/service_response_model.dart';

class ServiceState {
  final StateConstant configState;
  final List<ServiceResponseModel> services;
  final String? error;
  final int limit;

  const ServiceState({
    this.configState = StateConstant.loading,
    this.services = const [],
    this.error,
    this.limit = 20,
  });

  ServiceState copyWith({
    StateConstant? configState,
    List<ServiceResponseModel>? services,
    String? error,
    bool clearError = false,
    int? limit,
  }) {
    return ServiceState(
      configState: configState ?? this.configState,
      services: services ?? this.services,
      error: clearError ? null : (error ?? this.error),
      limit: limit ?? this.limit,
    );
  }
}
