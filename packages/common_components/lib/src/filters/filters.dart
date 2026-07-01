/// Generic filter system for common_components
///
/// This module provides a reusable, generic filter page system that can be
/// used across all features (listings, jobs, services, events, etc.)
///
/// ## Architecture
///
/// - **Models**: FilterOption, FilterSection, GenericFilterConfig, GenericFilterState
/// - **Provider**: GenericFilterNotifier & genericFilterProvider for state management
/// - **Widgets**: GenericFilterPage (main), SingleSelectSection, MultiSelectSection
///
/// ## Usage
///
/// Each feature creates its own filter page that:
/// 1. Defines feature-specific GenericFilterConfig
/// 2. Wraps GenericFilterPage with feature configuration
/// 3. Implements conversion from GenericFilterState to feature-specific filters
///
/// Example:
/// ```dart
/// // In listing feature
/// class ListingFilterPage extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return GenericFilterPage(
///       config: listingFilterConfig,
///       onApply: (filterState) {
///         // Convert and apply filters
///       },
///     );
///   }
/// }
/// ```
library;

// Models
export 'models/generic_filter_model.dart';

// Providers
export 'providers/generic_filter_provider.dart';

// Widgets
export 'widgets/generic_filter_page.dart';
export 'widgets/single_select_section.dart';
export 'widgets/multi_select_section.dart';
