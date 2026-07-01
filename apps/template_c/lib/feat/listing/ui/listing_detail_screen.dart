import 'package:common_components/common_components.dart';
import 'package:common_components/src/handler/launcher_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/router/route_constant.dart';

import 'package:template_c/feat/listing/controller/listing_detail_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_about_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_app_bar.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_bottom_cta.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_facts_row.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_map_widget.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/home/widgets/listing/listing_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_organizer_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/detail_title_widget.dart';
import 'package:template_c/feat/listing/ui/widgets/listing_image_carousel.dart';

class ListingDetailScreen extends BaseStatefulWidget {
  final String listingId;
  final String familyKey;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.familyKey = '',
  });

  @override
  String get screenName => RouteConstant.listingDetail.name;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState
    extends BaseStatefulWidgetState<ListingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final providerKey = (id: widget.listingId, familyKey: widget.familyKey);
    final state = ref.watch(listingDetailControllerProvider(providerKey));
    final listing = state.listing;

    return Scaffold(
      backgroundColor: context.templateColors.bgColor,
      appBar: DetailAppBar(providerKey: providerKey),
      body: switch (state.stateConstant) {
        StateConstant.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StateConstant.error => Center(child: Icon(Icons.error)),
        _ when listing == null => Center(child: Icon(Icons.error)),
        _ => _DetailBody(
          listing: listing,
          providerKey: providerKey,
          onFavTap: () => ref
              .read(listingDetailControllerProvider(providerKey).notifier)
              .toggleFav(),
        ),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY — assembles all section widgets, no UI logic here
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends BaseStatelessWidget {
  final ListingModel listing;
  final ({String id, String familyKey}) providerKey;

  final VoidCallback onFavTap;

  const _DetailBody({
    required this.listing,
    required this.providerKey,
    required this.onFavTap,
  });

  List<String> get _imageUrls {
    final seen = <String>{};
    final urls = <String>[];
    for (final url in [
      if (listing.resolvedImageUrl != null) listing.resolvedImageUrl!,
      ...?listing.media
          ?.where((m) => m.type == 'image' && m.url?.isNotEmpty == true)
          .map((m) => m.url!),
    ]) {
      if (seen.add(url)) urls.add(url);
    }
    return urls;
  }

  bool get _hasMap => listing.geoLat != null && listing.geoLng != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeDate = resolvedBadgeDate(listing);

    final dayText = badgeDate?.day.toString() ?? '';
    final monthText = badgeDate != null ? monthAbbr(badgeDate.month) : '';

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ── Carousel ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: ListingImageCarousel(
                  imageUrls: _imageUrls,
                  categoryFallbackImage: listing.imageFallback,
                  day: dayText,
                  month: monthText,
                  isFavorite: listing.isFavorite ?? false,
                  height: 361.h,
                  borderRadius: 20,
                  badgeBorderRadius: 8,
                  onFavoriteTap: onFavTap,
                ),
              ),
            ),

            // ── Title + tags ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: DetailTitleWidget(
                title: listing.title ?? '',
                categoryTitle: listing.categoryTitle,
                subcategoryTitle: listing.subcategoryTitle,
              ),
            ),

            // ── Facts row ────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.only(bottom: 36.h),
              sliver: SliverToBoxAdapter(
                child: DetailFactsRow(providerKey: providerKey),
              ),
            ),

            // ── Accessibility — section removed (no API data) ────────────

            // ── About — only if content or summary present ───────────────
            if (listing.content?.isNotEmpty == true) ...[
              SliverToBoxAdapter(
                child: DetailAboutWidget(content: listing.content),
              ),
              SliverToBoxAdapter(child: const _SectionDivider()),
            ],

            // ── Map — only if coordinates present ────────────────────────
            if (_hasMap)
              SliverPadding(
                padding: EdgeInsets.only(bottom: 60.h),
                sliver: SliverToBoxAdapter(
                  child: DetailMapWidget(
                    lat: listing.geoLat!,
                    lng: listing.geoLng!,
                    address: listing.address ?? '',
                  ),
                ),
              ),

            // ── Organizer — only if publisher name present ────────────────
            if (listing.organizer != null) ...[
              SliverToBoxAdapter(
                child: DetailOrganizerWidget(organizer: listing.organizer!),
              ),
              SliverToBoxAdapter(child: const _SectionDivider()),
            ],

            // ── More dates ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Visibility(
                visible: false,
                child: ListingWidget(
                  key: ValueKey(ListingFamilyKey.moreDates(providerKey.id)),
                  variant: HomeScreenConstant.contentSliderV3,
                  maxItems: 4,
                  filterKey: 'more_dates_${providerKey.id}',
                  sectionTitle: 'listing_detail_more_dates'.tr,
                  scrollDirection: Axis.vertical,

                  initialFilter: ListingFilterModel(
                    categorySlug: listing.categorySlug,
                    subcategorySlug: listing.subcategorySlug,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Visibility(visible: false, child: const _SectionDivider()),
            ),

            // ── Similar events ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: ListingWidget(
                key: ValueKey(ListingFamilyKey.similarEvents(providerKey.id)),
                variant: HomeScreenConstant.contentSliderV2,
                filterKey: 'similar_${providerKey.id}',
                sectionTitle: 'listing_detail_similar_events'.tr,
                scrollDirection: Axis.horizontal,
                initialFilter: ListingFilterModel(
                  categorySlug: listing.categorySlug,
                  subcategorySlug: listing.subcategorySlug,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: listing.registrationUrl?.isNotEmpty == true
                    ? 100.h
                    : 32.h,
              ),
            ),
          ],
        ),

        // ── Sticky bottom CTA — only if registrationUrl present ───────────
        if (listing.registrationUrl?.isNotEmpty == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DetailBottomCta(
              registrationUrl: listing.registrationUrl,
              onTap: () => ref
                  .read(launcherHandler)
                  .executeAction(context, listing.registrationUrl!),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 120.h,
      thickness: 8.h,
      color: Theme.of(context).dividerTheme.color,
    );
  }
}
