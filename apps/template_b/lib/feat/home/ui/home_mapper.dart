import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_screen.dart';
import 'package:template_b/feat/listing/presentation/widgets/listing_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/constants/home_screen_constant.dart';
import 'package:template_b/feat/handler/template_b_handler.dart';
import 'package:template_b/feat/sub_service/model/response/service_response_model.dart';
import 'package:template_b/feat/home/controller/home_controller.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';
import '../data/models/home_config.dart';
import 'widgets/header_widget.dart';
import 'widgets/category_widget.dart';
import 'widgets/locality_widget.dart';
import 'widgets/banner_widget.dart';
import 'widgets/company_profile_widget.dart';
import 'widgets/partners_widget.dart';

class HomeMapper {
  static double get _sectionSpacing => 24.h;

  /// Entry point — returns widget based on config availability
  /// Config is pre-loaded in SplashController, so no initial loading state needed
  static Widget buildHome(
    HomeConfigModel? config,
    GlobalKey<ScaffoldState> scaffoldKey,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (config == null) {
      return CommonCircularProgessIndicator();
    }

    // Show actual content with fade-in animation and refresh loading in body
    return CustomScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: mapToSlivers(config, scaffoldKey, context, ref),
    );
  }

  /// Entry point — builds all slivers from config
  static List<Widget> mapToSlivers(
    HomeConfigModel config,
    GlobalKey<ScaffoldState> scaffoldKey,
    BuildContext context,
    WidgetRef ref,
  ) {
    final homeState = ref.watch(homeProvider);

    final slivers = <Widget>[];

    // Header (combines header image + search bar + hamburger menu)
    // Always rendered so hamburger/search remain visible even when header image is hidden.
    // backgroundImage is only passed when header.visible is true.
    slivers.add(_buildHeader(config, scaffoldKey));
    // Pull to refresh
    slivers.add(
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          return ref.read(homeProvider.notifier).refresh();
        },
      ),
    );
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: _sectionSpacing)));

    slivers.addAll(_buildBodySections(config, context, ref));

    // Bottom padding for nav bar
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: 92.h)));

    return slivers;
  }

  /// Builds header widget with search bar and hamburger menu visibility
  static Widget _buildHeader(
    HomeConfigModel config,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Builder(
      builder: (context) {
        return HeaderWidget(
          backgroundImage: (config.header?.visible ?? false)
              ? config.header?.image
              : null,
          showSearchBar: config.searchBar?.visible ?? false,
          showHamburgerMenu: config.hamburgerMenu?.visible ?? false,
          onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
          onSearchTap: () {
            context.pushNamed(
              AppRouteConstants.featureListing.name,
              extra: ListingScreenParams(
                isSearch: true,
                categorySlug: 'search',
              ),
            );
          },
        );
      },
    );
  }

  /// Builds body sections with custom ordering based on locality variant
  static List<Widget> _buildBodySections(
    HomeConfigModel config,
    BuildContext context,
    WidgetRef ref,
  ) {
    final widgets = <Widget>[];
    final isDropdownVariant =
        config.localities?.variant == LocalityVariant.dropdown;

    // Define custom ordering based on locality variant
    final orderedSlugs = <HomeScreenConstant>[];

    if (isDropdownVariant) {
      // Flow 1: Dropdown variant - Localities first (after header)
      orderedSlugs.addAll([
        HomeScreenConstant.localities,
        HomeScreenConstant.quickActions,
        HomeScreenConstant.bannerImage,
        HomeScreenConstant.contentSlider,
        HomeScreenConstant.contentFeed,
        HomeScreenConstant.partners,
      ]);
    } else {
      // Flow 2: Slider variant - Localities after banner
      orderedSlugs.addAll([
        HomeScreenConstant.quickActions,
        HomeScreenConstant.bannerImage,
        HomeScreenConstant.localities,
        HomeScreenConstant.contentSlider,
        HomeScreenConstant.contentFeed,
        HomeScreenConstant.partners,
      ]);
    }

    // Build widgets in custom order
    for (final slug in orderedSlugs) {
      final widget = _buildWidget(slug, config, context, ref);
      if (widget != null) {
        if (widgets.isNotEmpty) {
          widgets.add(
            SliverToBoxAdapter(child: SizedBox(height: _sectionSpacing)),
          );
        }
        widgets.add(SliverToBoxAdapter(child: widget));
      }
    }

    return widgets;
  }

  /// Builds widget for a specific slug
  static Widget? _buildWidget(
    HomeScreenConstant slug,
    HomeConfigModel config,
    BuildContext context,
    WidgetRef ref,
  ) {
    return switch (slug) {
      HomeScreenConstant.quickActions => _buildQuickActions(
        config.quickActions,
        ref,
      ),
      HomeScreenConstant.localities => _buildLocalities(config.localities, ref),
      HomeScreenConstant.bannerImage => _buildBanner(config.banners, ref),
      HomeScreenConstant.contentSlider => _buildContentSlider(
        config.contentSlider,
        ref,
      ),
      HomeScreenConstant.contentFeed => _buildContentFeed(
        config.contentFeed,
        ref,
      ),
      HomeScreenConstant.partners => _buildPartners(config.partners),
      _ => null,
    };
  }

  /// Quick actions grid
  static Widget? _buildQuickActions(QuickActionsConfig? config, WidgetRef ref) {
    if (config == null || !config.visible || config.items.isEmpty) {
      return null;
    }

    return CategoryWidget(
      items: config.items,
      label: config.label,
      onItemTap: (item) {
        if (item.action != null) {
          final action = item.action!
            ..tenantServiceId = item.id
            ..serviceSlug = item.slug
            ..serviceImage = item.serviceImage;
          ref
              .read(templateBHandlerProvider)
              .executeAction(ref.context, action, title: item.label);
        }
      },
    );
  }

  /// Localities - slider or dropdown based on variant
  static Widget? _buildLocalities(LocalitiesConfig? config, WidgetRef ref) {
    if (config == null || !config.visible) {
      return null;
    }

    final homeState = ref.watch(homeProvider);

    // Get locality items from state (fetched from /api/localities)
    if (homeState.localityItems.isEmpty) {
      return null;
    }

    return Builder(
      builder: (builderContext) {
        return LocalityWidget(
          title: config.variant == LocalityVariant.slider ? config.label : null,
          items: homeState.localityItems,
          selectedItems: homeState.selectedLocalities,
          variant: config.variant,
          maxSelection: config.maxLocalities,
          hasNextPage: homeState.localityHasNextPage,
          isLoadingMore: homeState.isLoadingMoreLocalities,
          onItemTap: (item) {
            // Handle slider item tap - toggle selection
            final success = ref
                .read(homeProvider.notifier)
                .toggleLocalitySelection(item.id);

            // Show warning snackbar if max limit reached
            if (!success) {
              AppSnackBar.showError(
                builderContext,
                'maximum_localities_selected'.tr.replaceFirst(
                  '{count}',
                  '${config.maxLocalities}',
                ),
              );
            }
          },
          onSelectionChanged: (selectedItems) {
            // Handle dropdown selection change
            ref
                .read(homeProvider.notifier)
                .setSelectedLocalities(selectedItems);
          },
        );
      },
    );
  }

  /// Banner carousel — renders all banner_image entries as a swipeable carousel.
  static Widget? _buildBanner(List<BannerConfig> banners, WidgetRef ref) {
    // Filter to only visible banners that have an image
    final visible = banners.where((b) => b.visible && b.image != null).toList();

    if (visible.isEmpty) return null;

    return BannerWidget(
      banners: visible,
      onTap: (banner) {
        if (banner.action != null) {
          ref
              .read(templateBHandlerProvider)
              .executeAction(ref.context, banner.action!, title: banner.label);
        }
      },
    );
  }

  /// Content slider - horizontal scrolling (image + title only)
  static Widget? _buildContentSlider(
    ContentSliderConfig? config,
    WidgetRef ref,
  ) {
    if (config == null || !config.visible) {
      return null;
    }

    Widget? sliderWidget;

    final hasInlineItems = config.items != null && config.items!.isNotEmpty;
    final action = config.action;
    final isDirectAction =
        action != null && action.type != null && action.type != 'category';

    if (hasInlineItems) {
      // Inline items list — horizontal compact cards (103×126, image+gradient+title)
      sliderWidget = _buildInlineHorizontalItems(
        config.label,
        config.description,
        config.items!,
        ref,
      );
    } else if (action?.target == 'feature_job_matching') {
      // Feature-specific widget — must be checked before the generic isDirectAction guard
      sliderWidget = CompanyProfileWidget(
        title: config.label,
        description: config.description,
        category: action?.config?.category,
        maxItems: config.limit ?? 5,
        requiredLogin: action?.config?.requireLogin ?? false,
        requireShortCode: action?.config?.requiredShortCode ?? false,
      );
    } else if (action?.target == 'category') {
      sliderWidget = ListingWidget(
        title: config.label,
        description: config.description,
        maxItems: config.limit ?? 3,
        categorySlug: action?.config?.category ?? '',
        orientation: Axis.horizontal,
      );
    } else if (isDirectAction) {
      // Generic direct-action card — compact card shape (103×126 image fill + gradient)
      sliderWidget = _buildDirectActionCompactCard(
        label: config.label,
        description: config.description,
        image: config.image,
        title: config.title ?? config.label,
        subtitle: config.subtitle,
        action: action,
        ref: ref,
      );
    }

    if (sliderWidget == null) return null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sliderWidget,
          if (config.hypertext?.label?.isNotEmpty == true)
            GestureDetector(
              onTap: () {
                final htAction = config.hypertext?.action;
                if (htAction != null) {
                  ref
                      .read(templateBHandlerProvider)
                      .executeAction(
                        ref.context,
                        htAction,
                        title: config.hypertext?.label,
                      );
                }
              },
              child: Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Text(
                  config.hypertext?.label ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(ref.context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Partners widget
  static Widget? _buildPartners(PartnersConfig? config) {
    if (config == null || !config.visible || config.items.isEmpty) {
      return null;
    }
    return PartnersWidget(config: config);
  }

  /// Content feed listing - vertical (full card)
  static Widget? _buildContentFeed(ContentFeedConfig? config, WidgetRef ref) {
    if (config == null || !config.visible) {
      return null;
    }

    final hasInlineItems = config.items != null && config.items!.isNotEmpty;
    final action = config.action;
    final isDirectAction =
        action != null && action.type != null && action.type != 'category';

    if (hasInlineItems) {
      // Inline items list — vertical ListingItemWidget-shaped cards
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: _buildInlineVerticalItems(
          config.label,
          config.description,
          config.items!,
          ref,
        ),
      );
    }

    if (action?.target == 'feature_job_matching') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: CompanyProfileWidget(
          title: config.label,
          description: config.description,
          category: action?.config?.category,
          maxItems: config.limit ?? 5,
          requiredLogin: action?.config?.requireLogin ?? false,
          requireShortCode: action?.config?.requiredShortCode ?? false,
        ),
      );
    }

    if (action?.target == 'category') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListingWidget(
          title: config.label,
          description: config.description,
          maxItems: config.limit ?? 3,
          categorySlug: action?.config?.category ?? '',
          orientation: Axis.vertical,
        ),
      );
    }

    if (isDirectAction) {
      // Generic direct-action card — ListingItemWidget shape (image left, text right)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: _buildDirectActionVerticalCard(
          label: config.label,
          description: config.description,
          image: config.image,
          title: config.title ?? config.label,
          subtitle: config.subtitle,
          action: action,
          ref: ref,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListingWidget(
        title: config.label,
        maxItems: config.limit ?? 3,
        categorySlug: config.action?.config?.category ?? '',
        orientation: Axis.vertical,
      ),
    );
  }

  // ============================================================================
  // INLINE ITEMS — horizontal compact cards (same shape as _buildCompactCard)
  // ============================================================================

  static Widget _buildInlineHorizontalItems(
    String? sectionLabel,
    String? description,
    List<TemplateBActionItem> items,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionLabel != null && sectionLabel.isNotEmpty) ...[
          CommonText(
            titleText: sectionLabel,
            textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12.h),
        ],
        if (description?.isNotEmpty == true) ...[
          CommonText(
            titleText: description!,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            maxLines: 2,
          ),
          SizedBox(height: 12.h),
        ],
        SizedBox(
          height: 126.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildInlineCompactCard(item, ref),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // INLINE ITEMS — vertical full cards (same shape as ListingItemWidget)
  // ============================================================================

  static Widget _buildInlineVerticalItems(
    String? sectionLabel,
    String? description,
    List<TemplateBActionItem> items,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionLabel != null && sectionLabel.isNotEmpty) ...[
          CommonText(
            titleText: sectionLabel,
            textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12.h),
        ],
        if (description?.isNotEmpty == true) ...[
          CommonText(
            titleText: description!,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            maxLines: 2,
          ),
          SizedBox(height: 12.h),
        ],
        for (final item in items) _buildInlineVerticalCard(item, ref),
      ],
    );
  }

  // ============================================================================
  // SINGLE DIRECT-ACTION CARD — compact (horizontal slider)
  // ============================================================================

  static Widget _buildDirectActionCompactCard({
    required String? label,
    required String? description,
    required String? image,
    required String? title,
    required String? subtitle,
    required ActionResponseModel? action,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty) ...[
          CommonText(
            titleText: label,
            textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12.h),
        ],
        if (description?.isNotEmpty == true) ...[
          CommonText(
            titleText: description!,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            maxLines: 2,
          ),
          SizedBox(height: 12.h),
        ],
        SizedBox(
          height: 126.h,
          child: _buildInlineCompactCard(
            TemplateBActionItem(
              image: image,
              title: title,
              subtitle: subtitle,
              action: action,
            ),
            ref,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // SINGLE DIRECT-ACTION CARD — vertical (content feed)
  // ============================================================================

  static Widget _buildDirectActionVerticalCard({
    required String? label,
    required String? description,
    required String? image,
    required String? title,
    required String? subtitle,
    required ActionResponseModel? action,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty) ...[
          CommonText(
            titleText: label,
            textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12.h),
        ],
        if (description?.isNotEmpty == true) ...[
          CommonText(
            titleText: description!,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            maxLines: 2,
          ),
          SizedBox(height: 12.h),
        ],
        _buildInlineVerticalCard(
          TemplateBActionItem(
            image: image,
            title: title,
            subtitle: subtitle,
            action: action,
          ),
          ref,
        ),
      ],
    );
  }

  // ============================================================================
  // CARD PRIMITIVES — matching existing listing card shapes exactly
  // ============================================================================

  /// Compact card: 103×126, image fill + gradient overlay + title (= _buildCompactCard shape)
  static Widget _buildInlineCompactCard(
    TemplateBActionItem item,
    WidgetRef ref,
  ) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: item.action != null
              ? () {
                  final action = item.action!
                    ..tenantServiceId = item.id
                    ..serviceImage = item.image;
                  ref
                      .read(templateBHandlerProvider)
                      .executeAction(context, action, title: item.displayTitle);
                }
              : null,
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
                  CommonImage(imagePath: item.image ?? '', fit: BoxFit.cover),
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
                        titleText: item.displayTitle,
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
        );
      },
    );
  }

  /// Vertical card: 103×126 image left, title+subtitle right (= ListingItemWidget shape)
  static Widget _buildInlineVerticalCard(
    TemplateBActionItem item,
    WidgetRef ref,
  ) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: InkWell(
            onTap: item.action != null
                ? () {
                    final action = item.action!
                      ..tenantServiceId = item.id
                      ..serviceImage = item.image;
                    ref
                        .read(templateBHandlerProvider)
                        .executeAction(
                          context,
                          action,
                          title: item.displayTitle,
                        );
                  }
                : null,
            borderRadius: BorderRadius.circular(8.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey, width: 0.2.w),
                  ),
                  width: 103.w,
                  height: 126.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CommonImage(
                      imagePath: item.image ?? '',
                      fit: BoxFit.cover,
                      width: 103.w,
                      height: 126.h,
                    ),
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        titleText: item.displayTitle,
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      if (item.subtitle?.isNotEmpty == true) ...[
                        SizedBox(height: 8.h),
                        CommonText(
                          titleText: item.subtitle!,
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
