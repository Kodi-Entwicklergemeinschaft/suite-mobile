import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generic_filter_model.dart';

/// Provider for generic filter state
final genericFilterProvider =
    NotifierProvider.autoDispose<GenericFilterNotifier, GenericFilterState>(() {
  return GenericFilterNotifier();
});

/// Notifier for managing generic filter state
class GenericFilterNotifier extends Notifier<GenericFilterState> {
  @override
  GenericFilterState build() {
    return const GenericFilterState();
  }

  /// Select a single option (for singleSelect sections)
  /// Deselects previous selection
  void selectOption(String sectionId, String optionId, {dynamic value}) {
    // Store the value if provided, otherwise store the optionId
    final valueToStore = value ?? optionId;
    state = state.updateSelection(sectionId, valueToStore);
  }

  /// Toggle an option for multi-select sections
  void toggleOption(String sectionId, String optionId) {
    final current = state.getSelection(sectionId) as List<String>? ?? [];
    final updated = List<String>.from(current);

    if (updated.contains(optionId)) {
      updated.remove(optionId);
    } else {
      updated.add(optionId);
    }

    state = state.updateSelection(sectionId, updated.isEmpty ? null : updated);
  }

  /// Set multiple options for a section (replaces current selection)
  void selectMultiple(String sectionId, List<String> optionIds) {
    state = state.updateSelection(
      sectionId,
      optionIds.isEmpty ? null : optionIds,
    );
  }

  /// Check if an option is selected in a multi-select section
  bool isOptionSelected(String sectionId, String optionId) {
    final selection = state.getSelection(sectionId);
    if (selection is List<String>) {
      return selection.contains(optionId);
    }
    return false;
  }

  /// Check if an option is selected in a single-select section
  bool isSingleOptionSelected(String sectionId, String optionId) {
    final selection = state.getSelection(sectionId);
    return selection == optionId;
  }

  /// Clear selections for a specific section
  void clearSection(String sectionId) {
    state = state.clearSection(sectionId);
  }

  /// Clear all selections
  void clearAll() {
    state = state.clearAll();
  }

  /// Check if any selections exist
  bool hasSelections() {
    return state.hasSelections();
  }

  /// Get all selections as a map
  Map<String, dynamic> getSelections() {
    return state.toMap();
  }
}
