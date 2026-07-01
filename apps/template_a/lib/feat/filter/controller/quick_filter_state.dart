import 'package:template_a/core/constant/state_constant.dart';
import '../data/models/quick_filter_response_model.dart';

class QuickFilterState {
  final StateConstant stateConstant;
  final List<FilterGroup> filterGroups;
  final List<String> selectedFilterIds;
  final String message;

  const QuickFilterState({
    this.stateConstant = StateConstant.loading,
    this.filterGroups = const [],
    this.selectedFilterIds = const [],
    this.message = '',
  });

  bool get hasActiveFilters => selectedFilterIds.isNotEmpty;

  QuickFilterState copyWith({
    StateConstant? stateConstant,
    List<FilterGroup>? filterGroups,
    List<String>? selectedFilterIds,
    String? message,
  }) {
    return QuickFilterState(
      stateConstant: stateConstant ?? this.stateConstant,
      filterGroups: filterGroups ?? this.filterGroups,
      selectedFilterIds: selectedFilterIds ?? this.selectedFilterIds,
      message: message ?? this.message,
    );
  }
}
