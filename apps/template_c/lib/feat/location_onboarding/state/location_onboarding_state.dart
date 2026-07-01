import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';

class LocationOnboardingState {
  final LocationItemModel? selectedLocation;
  final List<LocationItemModel> locations;
  final StateConstant stateConstant;
  final String? errorMessage;
  final bool isSubmitting;

  static const Object _unset = Object();

  LocationOnboardingState({
    required this.selectedLocation,
    required this.locations,
    required this.stateConstant,
    required this.errorMessage,
    this.isSubmitting = false,
  });

  LocationOnboardingState copyWith({
    Object? selectedLocation = _unset,
    List<LocationItemModel>? locations,
    StateConstant? stateConstant,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return LocationOnboardingState(
      selectedLocation: identical(selectedLocation, _unset)
          ? this.selectedLocation
          : selectedLocation as LocationItemModel?,
      locations: locations ?? this.locations,
      stateConstant: stateConstant ?? this.stateConstant,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

