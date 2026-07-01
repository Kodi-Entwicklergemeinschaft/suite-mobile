import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_a/feat/bottom_navigation/data/model/request/bottom_navigation_request_model.dart';
import 'package:template_a/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';
import 'package:template_a/feat/bottom_navigation/model/bottom_nav_bar_model.dart';
import 'package:template_a/feat/bottom_navigation/state/bottom_navigation_state.dart';
import 'package:template_a/feat/bottom_navigation/domain/usecase/bottom_navigation_usecase.dart';
import 'package:template_a/router/router_provider.dart';

final bottomNavigationProvider =
    NotifierProvider<BottomNavigationController, BottomNavigationState>(
      BottomNavigationController.new,
    );

class BottomNavigationController extends Notifier<BottomNavigationState> {
  BottomNavigationUsecase get _usecase =>
      ref.read(bottomNavigationUseCaseProvider);

  @override
  BottomNavigationState build() => const BottomNavigationState();

  void registerFcmToken() {
    // notifications package not enabled — no-op
  }

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _usecase.call(BottomNavigationRequestModel());

      res.fold((l) => debugPrint('bottom_nav loadConfig error: $l'), (r) {
        final response = r as BottomNavigationResponseModel;

        final navBarModel = BottomNavBarModel(
          items: (response.data ?? []).map((item) {
            return NavItemModel(
              label: (item.nickname != null && item.nickname!.isNotEmpty)
                  ? item.nickname
                  : item.label,
              iconUrl: item.iconUrl ?? '',
            );
          }).toList(),
        );

        state = state.copyWith(
          bottomNavigationResponseModel: response,
          bottomNavBarModel: navBarModel,
        );

        // Setting shellConfigProvider triggers routerProvider to rebuild
        // because routerProvider watches shellConfigProvider directly.
        ref.read(shellConfigProvider.notifier).setConfig(response.data);
      });
    } catch (e) {
      debugPrint('bottom_nav loadConfig exception: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Re-fetches labels/icons in the current language and updates the widget
  /// state only — does NOT touch shellConfigProvider so the router is not
  /// rebuilt and navigation is not reset.
  Future<void> refreshLabels() async {
    try {
      final res = await _usecase.call(BottomNavigationRequestModel());
      if (!ref.mounted) return;

      res.fold(
        (l) => debugPrint('bottom_nav refreshLabels error: $l'),
        (r) {
          final response = r as BottomNavigationResponseModel;
          final navBarModel = BottomNavBarModel(
            items: (response.data ?? []).map((item) {
              return NavItemModel(
                label: (item.nickname != null && item.nickname!.isNotEmpty)
                    ? item.nickname
                    : item.label,
                iconUrl: item.iconUrl ?? '',
              );
            }).toList(),
          );
          state = state.copyWith(bottomNavBarModel: navBarModel);
        },
      );
    } catch (e) {
      debugPrint('bottom_nav refreshLabels exception: $e');
    }
  }
}
