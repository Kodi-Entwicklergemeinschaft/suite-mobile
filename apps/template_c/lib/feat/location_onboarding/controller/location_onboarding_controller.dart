import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_preference_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/request_model/location_request_model.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';
import 'package:template_c/feat/location_onboarding/domain/usecase/location_preference_usecase.dart';
import 'package:template_c/feat/location_onboarding/domain/usecase/location_usecase.dart';
import 'package:template_c/feat/location_onboarding/state/location_onboarding_state.dart';
import 'package:template_c/feat/open_street_map/controller/map_with_radius_controller.dart';

final locationOnboardingControllerProvider =
    NotifierProvider.autoDispose<LocationOnboardingController, LocationOnboardingState>(
      () => LocationOnboardingController(),
    );

class LocationOnboardingController extends Notifier<LocationOnboardingState> {
  LocationUsecase get _locationUsecase => ref.read(locationUseCaseProvider);

  late AppPreferenceManager _appPreferenceManager;

  @override
  LocationOnboardingState build() {
    _appPreferenceManager=ref.read(preferenceManagerProvider);

    return LocationOnboardingState(
      selectedLocation: null,
      locations: const [],
      stateConstant: StateConstant.initial,
      errorMessage: null,
    );
  }

  Future<void> searchLocations(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = state.copyWith(
        selectedLocation: null,
        locations: const [],
        // stateConstant: StateConstant.success,
        errorMessage: null,
      );
      return;
    }

    if (q.length < 2) {
      state = state.copyWith(
        selectedLocation: null,
        locations: const [],
        // stateConstant: StateConstant.success,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      stateConstant: StateConstant.loading,
      errorMessage: null,
    );

    try {
      final result = await _locationUsecase.call(LocationRequestModel(name: q));

      result.fold(
        (l) {
          debugPrint('Location search failed: $l');
          state = state.copyWith(
            locations: const [],
            stateConstant: StateConstant.error,
            errorMessage: l.toString(),
          );
        },
        (r) {
          state = state.copyWith(
            locations: r,
            stateConstant: StateConstant.success,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      debugPrint('Location search exception: $e');
      state = state.copyWith(
        locations: const [],
        stateConstant: StateConstant.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectLocation(LocationItemModel? location) {
    state = state.copyWith(
      selectedLocation: location,
      // stateConstant: StateConstant.success,
      errorMessage: null,
    );
  }

  Future<bool> updateLocationPreference({required String initialLocalityName,required double initialLat,required double initialLon,}) async {
    final selected = state.selectedLocation;
    // if (selected == null) return false;

    final lat = double.tryParse(selected?.lat ?? initialLat.toString());
    final lon = double.tryParse(selected?.lon ?? initialLon.toString());
    if (lat == null || lon == null) return false;

    final radiusKm = ref.read(mapWithRadiusProvider).radiusKm;
    final localityName = selected?.displayName ?? selected?.name ?? initialLocalityName;

    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await ref
        .read(locationPreferenceUseCaseProvider)
        .call(
          LocationPreferenceRequestModel(
            latitude: lat,
            longitude: lon,
            radius: radiusKm,
            localityName: localityName,
          ),
        );

    return result.fold(
      (error) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.toString(),
        );
        return false;
      },
      (_) {
        _appPreferenceManager.saveString(StorageKeys.selectedLocation, localityName);
        _appPreferenceManager.saveDouble(StorageKeys.lat, lat);
        _appPreferenceManager.saveDouble(StorageKeys.long, lon);
        _appPreferenceManager.saveDouble(StorageKeys.radius, radiusKm);
        _appPreferenceManager.saveBool(StorageKeys.isOnboarded, true);

        state = state.copyWith(
          isSubmitting: false,
          clearError: true,
          stateConstant: StateConstant.success,
        );
        return true;
      },
    );
  }
}
