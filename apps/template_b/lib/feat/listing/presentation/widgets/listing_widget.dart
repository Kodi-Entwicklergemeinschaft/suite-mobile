import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import '../../data/models/listing_filter_model.dart';
import '../../data/models/listing_model.dart';
import '../../controllers/listing_provider.dart';
import '../../state/listing_state.dart';
import 'listing_item_widget.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_detail_screen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef OnListingTap = void Function(ListingModel listing);
typedef OnMoreTap = void Function();

/// Embeddable listing section widget - shows limited items with "See More" button
/// Can be used in home screen or any other screen
class ListingWidget extends BaseStatefulWidget {
  final String? title;
  final String? description;
  final int maxItems;
  final String categorySlug;
  final ListingFilterModel? initialFilter;
  final OnListingTap? onListingTap;
  final OnMoreTap? onMoreTap;
  final Axis orientation;

  const ListingWidget({
    super.key,
    this.title,
    this.description,
    this.maxItems = 3,
    required this.categorySlug,
    this.initialFilter,
    this.onListingTap,
    this.onMoreTap,
    this.orientation = Axis.vertical,
  });

  @override
  ConsumerState<ListingWidget> createState() => _ListingWidgetState();
}

class _ListingWidgetState extends BaseStatefulWidgetState<ListingWidget> {
  late String _familyKey;

  @override
  void initState() {
    super.initState();
    _familyKey = '${widget.categorySlug}_widget';
    // Apply initial filter with categorySlug
    Future.microtask(() {
      final filter =
          widget.initialFilter ??
          ListingFilterModel(
            categorySlug: widget.categorySlug.isNotEmpty
                ? widget.categorySlug
                : null,
          );
      ref
          .read(listingFilterProviderFamily(_familyKey).notifier)
          .updateFilter(filter);
    });
  }

  /// Internal handler for listing item tap with smart defaults
  void _handleListingTap(ListingModel listing) {
    if (widget.onListingTap != null) {
      widget.onListingTap!(listing);
    } else {
      // Default: navigate to detail screen
      context.pushNamed(
        AppRouteConstants.featureListingDetail.name,
        extra: ListingDetailScreenParams(listingId: listing.id ?? ''),
      );
    }
  }

  /// Internal handler for "See More" tap with smart defaults
  void _handleMoreTap() {
    if (widget.onMoreTap != null) {
      widget.onMoreTap!();
    } else {
      // Default: navigate to full listing with same categorySlug
      context.pushNamed(
        AppRouteConstants.featureListing.name,
        extra: ListingScreenParams(
          categorySlug: widget.categorySlug,
          title: widget.title,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listingState = ref.watch(listingProviderFamily(_familyKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and optional "See All" for horizontal
        if (widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.description?.isNotEmpty == true ? 3.h : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CommonText(
                    titleText: widget.title!,
                    isHeader: true,
                    textStyle: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (widget.orientation == Axis.horizontal &&
                    listingState.totalListings > widget.maxItems &&
                    listingState.items.isNotEmpty)
                  Semantics(
                    button: true,
                    label: 'seeAll'.tr,
                    child: GestureDetector(
                      onTap: _handleMoreTap,
                      child: ExcludeSemantics(
                        child: CommonText(
                          titleText: 'seeAll'.tr,
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.description?.isNotEmpty == true)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CommonText(
              titleText: widget.description!,
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
            ),
          ),
        // Loading state
        if (listingState.isLoading)
          widget.orientation == Axis.horizontal
              ? _buildHorizontalShimmer()
              : _buildVerticalShimmer()
        // Error state
        else if (listingState.error != null)
          SizedBox(
            height: 200,
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
          )
        // Empty state
        else if (listingState.items.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        // Listings list
        else
          widget.orientation == Axis.horizontal
              ? _buildHorizontalList(listingState)
              : _buildVerticalList(listingState),
        // "See All" button at bottom left (only for vertical)
        if (widget.orientation == Axis.vertical &&
            listingState.totalListings > widget.maxItems &&
            listingState.items.isNotEmpty)
          Semantics(
            button: true,
            label: 'seeAll'.tr,
            child: GestureDetector(
              onTap: _handleMoreTap,
              child: ExcludeSemantics(
                child: CommonText(
                  titleText: 'seeAll'.tr,
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build vertical list (default - full card)
  Widget _buildVerticalList(ListingState listingState) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listingState.items.take(widget.maxItems).length,
      itemBuilder: (context, index) {
        final listing = listingState.items[index];
        return ListingItemWidget(
          listing: listing,
          onTap: () => _handleListingTap(listing),
        );
      },
    );
  }

  /// Build horizontal list (compact - image + title only)
  Widget _buildHorizontalList(ListingState listingState) {
    return SizedBox(
      height: 126.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listingState.items.take(widget.maxItems).length,
        itemBuilder: (context, index) {
          final listing = listingState.items[index];
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _buildCompactCard(listing),
          );
        },
      ),
    );
  }

  /// Build compact card for horizontal list (image + title overlay)
  Widget _buildCompactCard(ListingModel listing) {
    return Semantics(
      button: true,
      label: listing.title ?? '',
      child: GestureDetector(
        onTap: () => _handleListingTap(listing),
        child: ExcludeSemantics(
          child: Container(
            width: 103.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  CommonImage(
                    imagePath: (listing.heroImageUrl?.isNotEmpty == true)
                        ? listing.heroImageUrl!
                        : (listing.categoryFallbackImage ?? ''),
                    fit: BoxFit.cover,
                    errorWidget:
                        (listing.heroImageUrl?.isNotEmpty == true &&
                            listing.categoryFallbackImage?.isNotEmpty == true)
                        ? (context, error, stack) => CommonImage(
                            imagePath: listing.categoryFallbackImage!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: CommonText(
                        titleText: listing.title ?? '',
                        textStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build vertical shimmer skeleton (full cards)
  Widget _buildVerticalShimmer() {
    return Semantics(
      label: 'loading_label'.tr,
      excludeSemantics: true,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.maxItems,
        itemBuilder: (context, index) {
          return CommonShimmer(
            enabled: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                height: 140.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build horizontal shimmer skeleton (compact cards)
  Widget _buildHorizontalShimmer() {
    return SizedBox(
      height: 126.h,
      child: Semantics(
        label: 'loading_label'.tr,
        excludeSemantics: true,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.maxItems,
          itemBuilder: (context, index) {
            return CommonShimmer(
              enabled: true,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Container(
                  width: 103.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
