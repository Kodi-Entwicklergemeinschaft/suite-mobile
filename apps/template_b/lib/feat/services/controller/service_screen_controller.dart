import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/feat/services/state/service_screen_state.dart';
import 'package:template_b/feat/services/domain/use_case/service_usecase.dart';
import 'package:template_b/feat/services/model/request/get_service_config_request_model.dart';

final serviceScreenProvider =
    NotifierProvider.autoDispose<ServiceScreenController, ServiceScreenState>(
      () => ServiceScreenController(),
    );

class ServiceScreenController extends Notifier<ServiceScreenState> {
  ServiceUsecase get _serviceUsecase => ref.read(serviceUsecaseProvider);

  @override
  build() {
    return ServiceScreenState(true, [], 1);
  }

  Future<void> getServiceConfig({
    required int pageNumer,
    String? searchValue,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      GetServiceConfigRequestModel params = GetServiceConfigRequestModel(
        page: pageNumer,
        search: searchValue,
      );

      final result = await _serviceUsecase.call(params);

      result.fold(
        (l) {
          debugPrint('fold exception while fetching service config: $l');
        },
        (r) {
          final items = r.data?.items ?? [];
          final hasNext = r.data?.meta?.hasNextPage == true;
          final nextPage = hasNext ? pageNumer + 1 : pageNumer;

          if (pageNumer > 1) {
            state = state.copyWith(
              services: [...state.services, ...items],
              pageNumber: nextPage,
              hasNextPage: hasNext,
            );
            return;
          }

          state = state.copyWith(
            services: items,
            pageNumber: nextPage,
            hasNextPage: hasNext,
          );
        },
      );
    } catch (e) {
      debugPrint('Error fetching service config: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
