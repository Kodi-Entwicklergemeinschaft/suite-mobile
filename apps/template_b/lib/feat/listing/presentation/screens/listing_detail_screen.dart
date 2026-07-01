import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:template_b/feat/listing/data/models/listing_model.dart';
import 'package:template_b/feat/listing/controllers/listing_detail_provider.dart';
import 'package:template_b/feat/listing/state/listing_detail_state.dart';
import 'package:template_b/feat/listing/presentation/widgets/contact_info_widget.dart';
import 'package:template_b/feat/listing/presentation/widgets/event_info_widget.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/listing/presentation/widgets/listing_carousel_widget.dart';
import 'package:template_b/feat/listing/presentation/widgets/user_info_card_widget.dart';
import '../../../../core/utils/listing_utils.dart';
import 'package:html/parser.dart' as html_parser;

class ListingDetailScreenParams {
  final String listingId;
  final bool bySlug;

  ListingDetailScreenParams({required this.listingId, this.bySlug = false});
}

/// Full detail screen for a single listing
class ListingDetailScreen extends BaseStatefulWidget {
  final String listingId;
  final bool bySlug;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.bySlug = false,
  });

  @override
  String get screenName => AppRouteConstants.featureListingDetail.name;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState
    extends BaseStatefulWidgetState<ListingDetailScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(listingDetailProvider.notifier)
          .fetchListing(widget.listingId, bySlug: widget.bySlug);
    });
  }

  String stripHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(listingDetailProvider);

    return Scaffold(
      body: switch ((state.isLoading, state.error, state.listing)) {
        // Loading state
        (true, _, _) => const CommonCircularProgessIndicator(),

        // Error state
        (false, String _, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: 16.h),
              CommonText(
                titleText: 'errorTitle'.tr,
                isLiveRegion: true,
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: 8.h),
              AppButton(
                'retryButton'.tr,
                onPressed: () => ref
                    .read(listingDetailProvider.notifier)
                    .fetchListing(widget.listingId, bySlug: widget.bySlug),
              ),
            ],
          ),
        ),

        // Success state with data
        (false, null, ListingModel listing) => _buildDetailScreen(
          listing,
          theme,
          state,
        ),

        // Empty/initial state
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildDetailScreen(
    ListingModel listing,
    ThemeData theme,
    ListingDetailState detailState,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // SliverAppBar with collapsible header
        CommonSliverAppBar(
          expandedHeight: 250.h,
          pinned: true,
          actions: [
            // Favorite button
            // IconButton(
            //   icon: Icon(
            //     detailState.isFavorited
            //         ? Icons.favorite
            //         : Icons.favorite_border,
            //     color: detailState.isFavorited
            //         ? Colors.red
            //         : theme.colorScheme.onSurface,
            //   ),
            //   onPressed: () {
            //     ref
            //         .read(listingDetailProvider.notifier)
            //         .toggleFavorite(listing.id ?? '');
            //   },
            // ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              bottom: false,
              child: ListingCarouselWidget(
                heroImageUrl: listing.heroImageUrl,
                categoryFallbackImage: listing.categoryFallbackImage,
                media: listing.media,
              ),
            ),
          ),
        ),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Title
                CommonText(
                  titleText: listing.title ?? 'Untitled',
                  isHeader: true,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 8.h),

                // Date info
                if (listing.publishAt != null && listing.publishAt!.isNotEmpty)
                  CommonText(
                    titleText: formatDate(listing.publishAt!),
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                SizedBox(height: 12.h),

                // Summary/Description
                // if (listing.summary != null && listing.summary!.isNotEmpty)
                //   CommonText(
                //     titleText: listing.summary!,
                //     textStyle: theme.textTheme.bodyMedium,
                //     overflow: TextOverflow.visible,
                //   ),
                // SizedBox(height: 16.h),

                // Full Content with HTML rendering
                if (listing.content != null && listing.content!.isNotEmpty) ...[
                  CommonText(
                    titleText: 'description'.tr,
                    isHeader: true,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  HtmlContentWidget(
                    htmlContent: listing.content ?? '',
                    showMoreText: 'showMore'.tr,
                    showLessText: 'showLess'.tr,
                  ),
                  SizedBox(height: 16.h),
                ],

                // Contact Information
                ContactInfoWidget(listing: listing),
                SizedBox(height: 16.h),

                // Event Information
                EventInfoWidget(listing: listing),
                SizedBox(height: 16.h),

                // Tags Section
                if (listing.tags != null && listing.tags!.isNotEmpty) ...[
                  CommonText(
                    titleText: 'tags'.tr,
                    isHeader: true,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: listing.tags!.map((tag) {
                      return Chip(
                        label: CommonText(
                          titleText: tag.name ?? '',
                          textStyle: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: getTagColor(tag.color),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                ],

                // User Info Card
                UserInfoCardWidget(
                  organizerName: listing.organizerName,
                  organizerEmail: listing.contactEmail,
                  organizerPhone: listing.contactPhone,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
