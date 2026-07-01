import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_manager/shared_pref.dart';
import '../data/model/locality_delivery_model.dart';
import '../data/model/locality_model.dart';
import '../domain/usecase/fetch_localities_usecase.dart';
import '../domain/usecase/fetch_locality_delivery_usecase.dart';
import '../state/locality_selection_state.dart';

const int _kRecentLimit = 5;

String _recentSearchesKey(String serviceSlug) =>
    'locality_recent_searches_$serviceSlug';

String _lastSelectedKey(String serviceSlug) =>
    'locality_last_selected_$serviceSlug';

const String _usedSlugsKey = 'locality_used_slugs';

final localitySelectionControllerProvider = NotifierProvider.autoDispose<
    LocalitySelectionController,
    LocalitySelectionState>(LocalitySelectionController.new);

class LocalitySelectionController extends Notifier<LocalitySelectionState> {
  FetchLocalitiesUsecase get _fetchLocalities =>
      ref.read(fetchLocalitiesUsecaseProvider);

  FetchLocalityDeliveryUsecase get _fetchDelivery =>
      ref.read(fetchLocalityDeliveryUsecaseProvider);

  PreferenceManager get _prefs => ref.read(preferenceManagerProvider);

  Set<String>? _trackedSlugs;

  Set<String> get _slugs {
    if (_trackedSlugs != null) return _trackedSlugs!;
    final raw = _prefs.getStringOrNull(_usedSlugsKey);
    _trackedSlugs =
        raw != null ? Set<String>.from(jsonDecode(raw) as List) : {};
    return _trackedSlugs!;
  }

  @override
  LocalitySelectionState build() => const LocalitySelectionState();

  Future<void> initialize(String serviceSlug) async {
    state = state.copyWith(
      serviceSlug: serviceSlug,
      status: LocalitySelectionStatus.loading,
    );
    try {
      final locations = await _fetchLocalities(serviceSlug);
      final recentLocations = _loadRecentLocations(serviceSlug, locations);
      final lastSelected = _loadLastSelectedLocation(serviceSlug, locations);
      state = state.copyWith(
        status: LocalitySelectionStatus.loaded,
        allLocations: locations,
        recentLocations: recentLocations,
        selectedLocation: lastSelected,
        clearSelection: lastSelected == null,
      );
    } catch (_) {
      state = state.copyWith(
        status: LocalitySelectionStatus.error,
        errorMessage: 'dt_location_load_error',
      );
    }
  }

  void selectLocation(LocalityModel location) {
    state = state.copyWith(selectedLocation: location);
    _persistRecentLocation(location);
    _prefs.saveString(_lastSelectedKey(state.serviceSlug), location.id);
    _trackUsedSlug(state.serviceSlug);
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  Future<LocalityDeliveryModel?> confirmLocation() async {
    final location = state.selectedLocation;
    if (location == null) return null;

    state = state.copyWith(status: LocalitySelectionStatus.confirming);
    try {
      final delivery = await _fetchDelivery(state.serviceSlug, location.id);
      state = state.copyWith(status: LocalitySelectionStatus.loaded);
      return delivery;
    } catch (_) {
      state = state.copyWith(
        status: LocalitySelectionStatus.loaded,
        errorMessage: 'dt_location_load_error',
      );
      return null;
    }
  }

  void reset() => state = const LocalitySelectionState();

  LocalityModel? _loadLastSelectedLocation(
    String serviceSlug,
    List<LocalityModel> allLocations,
  ) {
    final id = _prefs.getStringOrNull(_lastSelectedKey(serviceSlug));
    if (id == null) return null;
    try {
      return allLocations.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void _trackUsedSlug(String serviceSlug) {
    if (_slugs.add(serviceSlug)) {
      _prefs.saveString(_usedSlugsKey, jsonEncode(_slugs.toList()));
    }
  }

  static Future<void> clearAllPersistedData(PreferenceManager prefs) async {
    final raw = prefs.getStringOrNull(_usedSlugsKey);
    final slugs =
        raw != null ? List<String>.from(jsonDecode(raw) as List) : <String>[];
    await Future.wait([
      for (final slug in slugs) prefs.removePreference(_lastSelectedKey(slug)),
      prefs.removePreference(_usedSlugsKey),
    ]);
  }

  List<LocalityModel> _loadRecentLocations(
    String serviceSlug,
    List<LocalityModel> allLocations,
  ) {
    final raw = _prefs.getStringOrNull(_recentSearchesKey(serviceSlug));
    if (raw == null) return [];
    try {
      final ids = List<String>.from(jsonDecode(raw) as List);
      final byId = {for (final l in allLocations) l.id: l};
      return ids
          .map((id) => byId[id])
          .whereType<LocalityModel>()
          .take(_kRecentLimit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _persistRecentLocation(LocalityModel location) {
    final currentIds = state.recentLocations.map((l) => l.id).toList();
    currentIds.remove(location.id);
    currentIds.insert(0, location.id);
    final limitedIds = currentIds.take(_kRecentLimit).toList();

    final updatedRecents = limitedIds
        .map((id) => state.allLocations.firstWhere((l) => l.id == id))
        .toList();

    state = state.copyWith(recentLocations: updatedRecents);
    _prefs.saveString(
      _recentSearchesKey(state.serviceSlug),
      jsonEncode(limitedIds),
    );
  }
}
