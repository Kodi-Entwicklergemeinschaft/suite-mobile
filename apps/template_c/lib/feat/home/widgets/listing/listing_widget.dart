import 'dart:developer';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/widgets/highlight_carousal.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/feat/home/widgets/listing/listing_loading.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/feat/listing/params/listing_screen_params.dart';
import 'package:template_c/router/route_constant.dart';

// ============================================================================
// LISTING WIDGET
// ============================================================================

class ListingWidget extends BaseStatefulWidget {
  final HomeScreenConstant variant;

  /// Appended to the family key to give each tab/context its own isolated
  /// provider instance. e.g. 'heute', 'morgen', 'montag'.
  /// Leave empty for the default view.
  final String filterKey;

  /// When provided, used as the fetch filter instead of the provider default.
  final ListingFilterModel? initialFilter;
  final String sectionTitle;
  final String actionLabel;
  final bool showActionChevron;
  final Axis scrollDirection;
  final int maxItems;
  final Widget? injectWidget;
  final int injectAtIndex;
  final void Function(int index)? onCardTap;
  final VoidCallback? onSeeAllTap;

  /// When true, appends a "show all" text card at the end of the horizontal
  /// slider — but only if the API reports more pages beyond the first load.
  final bool isSeeAllButton;

  const ListingWidget({
    super.key,
    required this.variant,
    this.filterKey = '',
    this.initialFilter,
    this.sectionTitle = '',
    this.actionLabel = 'home_see_all',
    this.showActionChevron = true,
    this.scrollDirection = Axis.horizontal,
    this.maxItems = 10,
    this.injectWidget,
    this.injectAtIndex = 3,
    this.onCardTap,
    this.onSeeAllTap,
    this.isSeeAllButton = false,
  });

  String get _familyKey => ListingFamilyKey.of(variant, filterKey);

  @override
  ConsumerState<ListingWidget> createState() => _ListingWidgetState();
}

class _ListingWidgetState extends BaseStatefulWidgetState<ListingWidget> {
  void _onSeeAllTap() {
    if (widget.onSeeAllTap != null) {
      widget.onSeeAllTap!();
      return;
    }
    // Map the home widget variant to the matching card layout for the See All screen.
    // V3 horizontal → subcategory card
    // V3 vertical   → moreDates card
    // V1 / V2       → full standard card
    final cardVariant = widget.variant == HomeScreenConstant.contentSliderV3
        ? (widget.scrollDirection == Axis.vertical
              ? ListingCardVariant.moreDates
              : ListingCardVariant.subcategory)
        : ListingCardVariant.standard;

    // Use the current active filter from the home provider so the See All
    // screen opens with the same filter context (dates, sort, etc.) already applied.
    final activeFilter =
        widget.initialFilter ??
        ref.read(listingControllerProvider(widget._familyKey)).filter;

    final params = ListingScreenParams(
      familyKey: ListingFamilyKey.seeAll(widget.filterKey),
      screenTitle: widget.sectionTitle,
      cardVariant: cardVariant,
      initialFilter: activeFilter.copyWith(page: 1),
    );
    context.pushNamed(RouteConstant.listingScreen.name, extra: params);
  }

  void _onCardTap(int index, List<ListingModel> models) {
    if (widget.onCardTap != null) {
      widget.onCardTap!(index);
      return;
    }
    final id = models[index].id;
    if (id == null || id.isEmpty) return;
    context.pushNamed(
      RouteConstant.listingDetail.name,
      pathParameters: {'id': id},
      queryParameters: {'familyKey': widget._familyKey},
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      log("Listing Widget family Key ${widget._familyKey}",name: 'ListingWidget');
      final notifier = ref.read(
        listingControllerProvider(widget._familyKey).notifier,
      );
      final filter =
          widget.initialFilter ??
          ref.read(listingControllerProvider(widget._familyKey)).filter;
      notifier.getListing(filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingControllerProvider(widget._familyKey));
    final items = state.listingModel;

    final isFirstLoad =
        state.stateConstant == StateConstant.loading && items.isEmpty;

    // V1 — pure carousel, no header
    if (widget.variant == HomeScreenConstant.contentSliderV1) {
      if (isFirstLoad) return const ListingShimmerV1();
      if (state.stateConstant == StateConstant.error || items.isEmpty) {
        return ListingStatusWidget(
          isEmpty:
              items.isEmpty && state.stateConstant == StateConstant.success,
          isError: state.stateConstant == StateConstant.error,
        );
      }
      return HighlightCarousel(
        items: items
            .map(
              (m) => ListingItemCard.highlight(
                model: m,
                familyKey: widget._familyKey,
                onTap: m.id?.isNotEmpty == true
                    ? () => _onCardTap(items.indexOf(m), items)
                    : null,
              ),
            )
            .toList(),
      );
    }

    // V2 / V3 — section header + list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CommonText(
                  titleText: widget.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              4.horizontalSpace,
              if (widget.variant == HomeScreenConstant.contentSliderV2 &&
                  state.stateConstant == StateConstant.success &&
                  items.isNotEmpty)
                if (widget.showActionChevron)
                  GestureDetector(
                    onTap: _onSeeAllTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CommonText(
                          titleText: widget.actionLabel.tr,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: TemplateCColors.textGrayV2,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        SvgPicture.asset(
                          'assets/svg/rounded_right_arrow.svg',
                          width: 17.w,
                          height: 17.h,
                        ),
                      ],
                    ),
                  )
                else
                  CommonText(
                    titleText: widget.actionLabel.tr,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: TemplateCColors.textGrayV2,
                    ),
                  ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        if (isFirstLoad)
          const ListingShimmerV2()
        else if (state.stateConstant == StateConstant.error)
          const ListingStatusWidget(isError: true)
        else if (items.isEmpty)
          const ListingStatusWidget(isEmpty: true)
        else if (widget.scrollDirection == Axis.vertical)
          _VerticalList(
            items: items,
            maxItems: widget.maxItems,
            injectWidget: widget.injectWidget,
            injectAtIndex: widget.injectAtIndex,
            compact: widget.variant == HomeScreenConstant.contentSliderV3,
            familyKey: widget._familyKey,
            onCardTap: (i) => _onCardTap(i, items),
            onSeeAllTap: _onSeeAllTap,
            isSeeAllButton: widget.isSeeAllButton,
            hasNextPage: state.hasNextPage,
          )
        else
          _HorizontalList(
            items: items,
            compact: widget.variant == HomeScreenConstant.contentSliderV3,
            familyKey: widget._familyKey,
            onCardTap: (i) => _onCardTap(i, items),
            onSeeAllTap: _onSeeAllTap,
            isSeeAllButton: widget.isSeeAllButton,
            hasNextPage: state.hasNextPage,
          ),
      ],
    );
  }
}

// ============================================================================
// PRIVATE LIST WIDGETS
// ============================================================================

class _HorizontalList extends StatelessWidget {
  final List<ListingModel> items;
  final bool compact;
  final String familyKey;
  final void Function(int)? onCardTap;
  final VoidCallback? onSeeAllTap;
  final bool isSeeAllButton;
  final bool hasNextPage;

  const _HorizontalList({
    required this.items,
    this.compact = false,
    this.familyKey = '',
    this.onCardTap,
    this.onSeeAllTap,
    this.isSeeAllButton = false,
    this.hasNextPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 304.w : 296.w;
    final cards = [
      for (int i = 0; i < items.length; i++)
        SizedBox(
          width: cardWidth,
          child: compact
              ? ListingItemCard.subcategory(
                  model: items[i],
                  onTap: onCardTap != null ? () => onCardTap!(i) : null,
                )
              : ListingItemCard(
                  model: items[i],
                  familyKey: familyKey,
                  onTap: onCardTap != null ? () => onCardTap!(i) : null,
                ),
        ),
      if (compact) _SeeAllCard(onTap: onSeeAllTap),
      if (isSeeAllButton && hasNextPage) _ShowAllTextCard(onTap: onSeeAllTap),
    ];

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) SizedBox(width: 12.w),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeAllCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _SeeAllCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96.w + 32.w,
        height: 96.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1.w,
          ),
        ),
        child: Center(
          child: CommonText(
            titleText: 'home_see_all'.tr,
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              color: TemplateCColors.lightModeBackground,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowAllTextCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _ShowAllTextCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Center(
          child: CommonText(
            titleText: 'home_see_all'.tr,
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalList extends BaseStatelessWidget {
  final List<ListingModel> items;
  final int maxItems;
  final Widget? injectWidget;
  final bool showInjectWidget;
  final int injectAtIndex;
  final bool compact;
  final String familyKey;
  final void Function(int)? onCardTap;
  final VoidCallback? onSeeAllTap;
  final bool isSeeAllButton;
  final bool hasNextPage;

  const _VerticalList({
    required this.items,
    required this.maxItems,
    this.injectWidget,
    this.showInjectWidget = true,
    required this.injectAtIndex,
    this.compact = false,
    this.familyKey = '',
    this.onCardTap,
    this.onSeeAllTap,
    this.isSeeAllButton = false,
    this.hasNextPage = false,
  });

  @override
  Widget build(BuildContext context, ref) {
    final displayItems = items.take(maxItems).toList();
    final shouldShowSeeAll = !compact && isSeeAllButton && hasNextPage;
    // compact appends a See All row; inject widget only applies to standard
    final itemCount = compact
        ? displayItems.length + 1
        : (injectWidget != null && displayItems.length > injectAtIndex
              ? displayItems.length + 1 + (shouldShowSeeAll ? 1 : 0)
              : displayItems.length + (shouldShowSeeAll ? 1 : 0));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (_, index) {
        if (!compact &&
            injectWidget != null &&
            (index == injectAtIndex - 1 || index == injectAtIndex)) {
          return const SizedBox.shrink();
        }
        return SizedBox(height: compact ? 12.h : 24.h);
      },
      itemBuilder: (context, index) {
        // See All row at end for compact
        if (compact && index == displayItems.length) {
          return _SeeAllRow(onTap: onSeeAllTap);
        }
        // See All row at end for non-compact when more pages exist
        if (shouldShowSeeAll && index == itemCount - 1) {
          return _SeeAllRow(onTap: onSeeAllTap);
        }
        if (!compact && injectWidget != null && index == injectAtIndex) {
          return injectWidget!;
        }
        final itemIndex =
            (!compact && injectWidget != null && index > injectAtIndex)
            ? index - 1
            : index;
        if (compact) {
          return ListingItemCard.moreDates(
            model: displayItems[itemIndex],
            onTap: onCardTap != null ? () => onCardTap!(itemIndex) : null,
          );
        }
        return ListingItemCard(
          model: displayItems[itemIndex],
          familyKey: familyKey,
          onTap: onCardTap != null ? () => onCardTap!(itemIndex) : null,
        );
      },
    );
  }
}

class _SeeAllRow extends StatelessWidget {
  final VoidCallback? onTap;

  const _SeeAllRow({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Text(
            'home_see_all'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.0,
              letterSpacing: 0,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
