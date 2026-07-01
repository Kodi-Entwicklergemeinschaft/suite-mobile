import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/utils/location_service.dart';
import 'package:template_a/feat/home/domain/usecases/get_home_config_usecase.dart';
import 'package:template_a/feat/home/state/home_state.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState(components: []);
  }

  Future<void> loadHomeConfig() async {
    state = state.copyWith(configState: StateConstant.loading);
    await LocationService().requestPermission();
    _fetchAndSaveLocation();
    final result = await ref
        .read(getHomeConfigUseCaseProvider)
        .call(const NoParams());
    result.fold(
      (error) {
        debugPrint('HomeController: home config error: $error');
        state = state.copyWith(configState: StateConstant.error);
      },
      (config) {
        state = state.copyWith(
          components: config.components,
          configState: StateConstant.success,
        );
      },
    );
  }

  Future<void> refresh() async {
    await LocationService().requestPermission();
    _fetchAndSaveLocation();
    final result = await ref
        .read(getHomeConfigUseCaseProvider)
        .call(const NoParams());
    result.fold(
      (error) {
        debugPrint('HomeController: home config refresh error: $error');
      },
      (config) {
        state = state.copyWith(
          components: config.components,
          configState: StateConstant.success,
        );
      },
    );
  }

  void _fetchAndSaveLocation() async {
    final position = await LocationService().getCurrentLocation();
    if (position == null) return;
    final prefs = ref.read(preferenceManagerProvider);
    await prefs.saveDouble(StorageKeys.lat, position.latitude);
    await prefs.saveDouble(StorageKeys.long, position.longitude);
  }
}
