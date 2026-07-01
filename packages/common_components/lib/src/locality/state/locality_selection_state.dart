import '../data/model/locality_model.dart';

enum LocalitySelectionStatus { initial, loading, loaded, confirming, error }

class LocalitySelectionState {
  final LocalitySelectionStatus status;
  final String serviceSlug;
  final List<LocalityModel> allLocations;
  final List<LocalityModel> recentLocations;
  final LocalityModel? selectedLocation;
  final String? errorMessage;

  const LocalitySelectionState({
    this.status = LocalitySelectionStatus.initial,
    this.serviceSlug = '',
    this.allLocations = const [],
    this.recentLocations = const [],
    this.selectedLocation,
    this.errorMessage,
  });

  LocalitySelectionState copyWith({
    LocalitySelectionStatus? status,
    String? serviceSlug,
    List<LocalityModel>? allLocations,
    List<LocalityModel>? recentLocations,
    LocalityModel? selectedLocation,
    bool clearSelection = false,
    String? errorMessage,
  }) {
    return LocalitySelectionState(
      status: status ?? this.status,
      serviceSlug: serviceSlug ?? this.serviceSlug,
      allLocations: allLocations ?? this.allLocations,
      recentLocations: recentLocations ?? this.recentLocations,
      selectedLocation:
          clearSelection ? null : selectedLocation ?? this.selectedLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
