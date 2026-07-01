import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/core/constant/state_constant.dart';
import '../../data/models/get_service_config_request_model.dart';
import '../../domain/usecases/get_service_config_usecase.dart';
import '../state/service_state.dart';

final serviceControllerProvider =
    NotifierProvider.family<ServiceController, ServiceState, String>(
  (arg) => ServiceController(arg),
);

class ServiceController extends Notifier<ServiceState> {
  final String arg;
  ServiceController(this.arg);

  @override
  ServiceState build() {
    return const ServiceState();
  }

  Future<void> fetchServices({
    int? limit,
    int page = 1,
  }) async {
    final effectiveLimit = limit ?? state.limit;
    state = state.copyWith(
      configState: StateConstant.loading,
      error: null,
      limit: effectiveLimit,
    );

    final params = GetServiceConfigRequestModel(
      page: page,
      limit: effectiveLimit,
    );

    final result = await ref.read(getServiceConfigUseCaseProvider).call(params);

    result.fold(
      (error) {
        state = state.copyWith(
          configState: StateConstant.error,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          configState: StateConstant.success,
          services: response.data?.items ?? [],
        );
      },
    );
  }

  Future<void> refresh() async {
    await fetchServices(limit: state.limit);
  }
}
