/// Generic filter models for reusable filter page system
///
/// Supports multiple filter types:
/// - Single select (radio button behavior)
/// - Multi-select (checkbox behavior)
/// - Date range (from/to date selection)
///
/// All labels come from backend (no translation keys)
library;

import 'package:flutter/foundation.dart';

/// Enum for filter selection types
enum FilterType {
  singleSelect,
  multiSelect,
  dateRange,
}

/// Represents a single filter option
class FilterOption {
  /// Unique identifier for this option
  final String id;

  /// Display label for the option (from backend, no translation)
  final String label;

  /// Value to be stored when this option is selected
  final dynamic value;

  const FilterOption({
    required this.id,
    required this.label,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ value.hashCode;

  FilterOption copyWith({
    String? id,
    String? label,
    dynamic value,
  }) {
    return FilterOption(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}

/// Represents a section of filters with the same type
class FilterSection {
  /// Unique identifier for this section
  final String id;

  /// Display title for the section (from backend, no translation)
  final String title;

  /// Type of filter selection for this section
  final FilterType type;

  /// List of filter options in this section
  final List<FilterOption> options;

  /// Whether users can deselect all options (default: true for singleSelect, false for multiSelect)
  final bool? allowNone;

  const FilterSection({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    this.allowNone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterSection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          type == other.type &&
          listEquals(options, other.options) &&
          allowNone == other.allowNone;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      type.hashCode ^
      options.hashCode ^
      allowNone.hashCode;

  FilterSection copyWith({
    String? id,
    String? title,
    FilterType? type,
    List<FilterOption>? options,
    bool? allowNone,
  }) {
    return FilterSection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      options: options ?? this.options,
      allowNone: allowNone ?? this.allowNone,
    );
  }
}

/// Complete filter configuration
class GenericFilterConfig {
  /// List of filter sections
  final List<FilterSection> sections;

  const GenericFilterConfig({
    required this.sections,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericFilterConfig &&
          runtimeType == other.runtimeType &&
          listEquals(sections, other.sections);

  @override
  int get hashCode => sections.hashCode;

  GenericFilterConfig copyWith({
    List<FilterSection>? sections,
  }) {
    return GenericFilterConfig(
      sections: sections ?? this.sections,
    );
  }
}

/// Represents the current state of all filter selections
class GenericFilterState {
  /// Map of sectionId -> selected value(s)
  /// For singleSelect: String value
  /// For multiSelect: List String of selected ids
  final Map<String, dynamic> selections;

  const GenericFilterState({
    this.selections = const {},
  });

  /// Get selection for a specific section
  /// Returns null if nothing selected
  dynamic getSelection(String sectionId) {
    return selections[sectionId];
  }

  /// Check if any selections exist
  bool hasSelections() {
    return selections.isNotEmpty &&
        selections.values.any((value) {
          if (value is List) return value.isNotEmpty;
          if (value is String) return value.isNotEmpty;
          return value != null;
        });
  }

  /// Get all selected values as a map (useful for API calls)
  Map<String, dynamic> toMap() => Map.from(selections);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericFilterState &&
          runtimeType == other.runtimeType &&
          mapEquals(selections, other.selections);

  @override
  int get hashCode => selections.hashCode;

  GenericFilterState copyWith({
    Map<String, dynamic>? selections,
  }) {
    return GenericFilterState(
      selections: selections ?? Map.from(this.selections),
    );
  }

  GenericFilterState updateSelection(String sectionId, dynamic value) {
    final newSelections = Map<String, dynamic>.from(selections);
    if (value == null || (value is List && value.isEmpty)) {
      newSelections.remove(sectionId);
    } else {
      newSelections[sectionId] = value;
    }
    return copyWith(selections: newSelections);
  }

  GenericFilterState clearSection(String sectionId) {
    final newSelections = Map<String, dynamic>.from(selections);
    newSelections.remove(sectionId);
    return copyWith(selections: newSelections);
  }

  GenericFilterState clearAll() {
    return const GenericFilterState();
  }
}
