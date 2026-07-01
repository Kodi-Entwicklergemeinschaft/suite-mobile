import 'package:common_components/common_components.dart';
import '../data/models/listing_filter_model.dart';

/// Convert backend filter config to GenericFilterConfig
/// Dynamically converts backend structure to filter sections
///
/// TODO: Backend restructuring required
/// - Once backend returns `sections` array format (id, title, type, options),
///   simplify this function to directly map sections without iteration
/// - This function will remain as fallback for dynamic key iteration
///
/// Current backend format (temporary):
/// {
///   "dateRange": { "label": "...", "items": [...] },
///   "locality": { "label": "...", "isMultiSelect": true, "items": [...] }
/// }
GenericFilterConfig convertBackendFilterConfig(dynamic backendConfig) {
  final sections = <FilterSection>[];

  // Iterate through each top-level key (e.g., 'dateRange', 'locality')
  backendConfig.forEach((sectionKey, sectionData) {
    if (sectionData is! Map) return;

    final items = sectionData['items'] as List? ?? [];
    if (items.isEmpty) return;

    // Determine filter type
    final isMultiSelect = sectionData['isMultiSelect'] as bool? ?? false;
    final isDateRange = sectionKey == 'dateRange';

    final filterType = isDateRange
        ? FilterType.dateRange
        : isMultiSelect
            ? FilterType.multiSelect
            : FilterType.singleSelect;

    // Convert items to FilterOptions
    final options = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map;

      // Use item name as label
      final label = item['name'] as String? ?? 'Option ${index + 1}';

      // Create value by excluding 'name' from item
      final value = Map<String, dynamic>.from(item);
      value.remove('name');

      return FilterOption(
        id: '${sectionKey}_$index', // Use section_index as implicit ID
        label: label,
        value: value, // {startDate, endDate} for dateRange, {localityId, ...} for others
      );
    }).toList();

    // Create FilterSection
    sections.add(FilterSection(
      id: sectionKey,
      title: sectionData['label'] as String? ?? _humanizeLabel(sectionKey),
      type: filterType,
      options: options,
    ));
  });

  return GenericFilterConfig(sections: sections);
}

/// Convert camelCase/snake_case to readable title
String _humanizeLabel(String key) {
  return key
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

/// Parse filter type string to FilterType enum
FilterType _parseFilterType(String type) {
  return switch (type) {
    'singleSelect' => FilterType.singleSelect,
    'multiSelect' => FilterType.multiSelect,
    'dateRange' => FilterType.dateRange,
    _ => FilterType.singleSelect,
  };
}

/// Convert GenericFilterState to ListingFilterModel
/// Only includes date range filters from backend config
ListingFilterModel convertToListingFilter(GenericFilterState filterState) {
  var eventStartFromStr;
  var eventStartToStr;

  final dateRangeSelection = filterState.getSelection('dateRange');
  if (dateRangeSelection is Map) {
    eventStartFromStr = dateRangeSelection['startDate'] as String?;
    eventStartToStr = dateRangeSelection['endDate'] as String?;
  }

  return ListingFilterModel(
    eventStartFrom: eventStartFromStr,
    eventStartTo: eventStartToStr,
  );
}
