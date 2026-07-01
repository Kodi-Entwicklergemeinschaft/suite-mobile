import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:go_router/go_router.dart';
import '../../config/listing_filter_config.dart';
import '../../controllers/listing_provider.dart';
import '../../data/models/listing_filter_config_response_model.dart';
import 'package:template_b/routes/app_routes.dart';

/// Listing feature filter page
///
/// Fetches filter configuration from API based on category slug
/// Converts API response to GenericFilterConfig for display
/// Handles filter application and listing updates
class ListingFilterPage extends BaseStatelessWidget {
  final String familyKey;
  final String categorySlug;

  const ListingFilterPage({
    super.key,
    this.familyKey = 'default_screen',
    this.categorySlug = 'default',
  });

  /// Convert API FilterConfigData to GenericFilterConfig
  /// TODO: Backend API restructuring required
  /// - Backend should return filters in `sections` array format with id, title, type, options
  /// - Once backend is updated, use convertBackendFilterConfig() from listing_filter_config.dart
  /// - Currently disabled pending backend restructuring
  GenericFilterConfig _buildFilterConfigFromApi(FilterConfigData? data) {
    // TODO: Implement once backend API returns sections array format
    // For now, return empty config to prevent type casting errors
    return GenericFilterConfig(sections: []);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filter config from provider
    final filterConfigAsync = ref.watch(
      listingFilterConfigProviderFamily(categorySlug),
    );

    return filterConfigAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Filters')),
        body: const CommonCircularProgessIndicator(),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Filters')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.error_outline, size: 48, color: Colors.red),
              ),
              SizedBox(height: 16),
              CommonText(
                titleText: 'Failed to load filters',
                isLiveRegion: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(listingFilterConfigProviderFamily(categorySlug));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (filterConfigData) {
        // Convert API data to GenericFilterConfig
        final filterConfig = _buildFilterConfigFromApi(filterConfigData);

        return GenericFilterPage(
          config: filterConfig,
          onApply: (filterState) {
            // Convert generic filter state to listing filter
            final listingFilter = convertToListingFilter(filterState);

            // Update listing filter in controller using family key
            ref
                .read(listingFilterProviderFamily(familyKey).notifier)
                .updateFilter(listingFilter);

            // Reload listings with new filters
            ref.read(listingProviderFamily(familyKey).notifier).loadListings();

            // GenericFilterPage will handle the pop, so don't pop here
            // This ensures we go back to ListingScreen instead of Home
          },
        );
      },
    );
  }
}
