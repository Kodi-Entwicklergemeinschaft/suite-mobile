import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/dashbboard/model/request/dashboard_config_request_model.dart';
import 'package:template_b/feat/dashbboard/model/response/dashboard_config_response_model.dart';
import 'package:template_b/feat/dashbboard/state/dashboard_screen_state.dart';
import 'package:template_b/feat/dashbboard/domain/usecase/dashboard_usecase.dart';

final dashboardControllerProvider =
    NotifierProvider.autoDispose<DashboardController, DashboardScreenState>(
      () => DashboardController(),
    );

class DashboardController extends Notifier<DashboardScreenState> {
  DashboardUsecase get _dashboardUseCase => ref.read(dashboardUseCaseProvider);

  @override
  DashboardScreenState build() {
    return DashboardScreenState(true, []);
  }

  Future<void> getDashboardConfig() async {
    try {
      DashboardConfigRequestModel params = DashboardConfigRequestModel();

      final res = await _dashboardUseCase.call(params);

      res.fold(
        (l) {
          debugPrint('dashboard config fold exception: $l');
        },
        (r) {
          final result = r as DashboardConfigResponseModel;

          state = state.copyWith(
            serviceResponseModelList: result.serviceResponseModelList,
          );
        },
      );
    } catch (e) {
      debugPrint('Exception while getting dashboard config : $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
