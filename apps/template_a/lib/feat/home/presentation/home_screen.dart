import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/home/constants/home_screen_constant.dart';
import 'package:template_a/feat/home/controller/home_controller.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/home/widgets/content_slider_v4.dart';
import 'package:template_a/feat/home/widgets/content_slider_v5.dart';
import 'package:template_a/feat/home/widgets/content_slider_v6.dart';
import 'package:template_a/feat/home/widgets/sub_category_slider.dart';
import 'package:template_a/feat/bottom_navigation/presentation/bottom_navigation_screen.dart'
    show drawerScaffoldKey;
import 'package:template_a/feat/home/widgets/home_header_image.dart';
import 'package:template_a/feat/home/widgets/home_search_bar.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/home/widgets/tile_slider_carousel.dart';

import 'package:template_a/feat/listing/controller/listing_controller.dart';
import 'package:template_a/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_a/feat/services/presentation/controller/service_controller.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';

class HomeScreen extends BaseStatefulWidget {
  final String? tabSlug;
  const HomeScreen({super.key, this.tabSlug});

  @override
  String? get screenName => tabSlug;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseStatefulWidgetState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeControllerProvider.notifier).loadHomeConfig());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state.configState == StateConstant.loading) {
      return Scaffold(
        body: ShimmerWidget(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner placeholder
                Container(
                  height: 240.h,
                  width: double.infinity,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Positioned.fill(child: Container(color: Colors.white)),
                      Positioned(
                        bottom: 8.h,
                        left: 16.w,
                        right: 16.w,
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      // V4 banner skeleton
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5.r),
                        child: SizedBox(
                          height: 460.h,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Positioned.fill(child: Container(color: Colors.white)),
                              Positioned(
                                top: 25.h,
                                left: 0,
                                child: Container(
                                  height: 32.h,
                                  width: 140.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6.r),
                                      bottomRight: Radius.circular(6.r),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 40.h,
                                left: 0,
                                child: Container(
                                  height: 34.h,
                                  width: 200.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8.r),
                                      bottomRight: Radius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  height: 34.h,
                                  width: 160.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8.r),
                                      bottomRight: Radius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      // V5/V6 section skeletons
                      for (int i = 0; i < 3; i++) ...[
                        Container(
                          height: 21.h,
                          width: 160.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                          children: List.generate(
                            4,
                            (_) => Container(
                              width: 160.w,
                              height: 170.h,
                              margin: EdgeInsets.only(right: 12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 100.h,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 8.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            height: 11.h,
                                            width: 80.w,
                                            color: Colors.white),
                                        SizedBox(height: 4.h),
                                        Container(
                                            height: 13.h,
                                            width: 120.w,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.configState == StateConstant.error) {
      return Scaffold(
        body: Center(
          child: CommonText(
            titleText: 'error_loading'.tr,
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
    final visibleComponents = state.components.where((c) {
      if (!c.visible) return false;
      final loginRequired = c.loginRequired;
      if (loginRequired == null) return true;
      if (loginRequired == true) return !isGuest;
      return isGuest;
    }).toList().cast<ContentSliderConfig>();

    final headerImageComponent = visibleComponents.firstWhere(
      (c) => c.variant == HomeScreenConstant.headerImage,
      orElse: () => ContentSliderConfig(variant: HomeScreenConstant.headerImage),
    );
    final appIconComponent = visibleComponents.firstWhere(
      (c) => c.variant == HomeScreenConstant.appiconImage,
      orElse: () => ContentSliderConfig(variant: HomeScreenConstant.appiconImage),
    );
    final hasHeader = headerImageComponent.image != null &&
        headerImageComponent.image!.isNotEmpty;
    final hasSearchBar = visibleComponents.any(
      (c) => c.variant == HomeScreenConstant.searchBar,
    );
    final hasHamburger = visibleComponents.any(
      (c) => c.variant == HomeScreenConstant.hamburgerMenu,
    );
    final hasAppIcon = appIconComponent.image != null && appIconComponent.image!.isNotEmpty;
    final hasAppBar = hasHeader || hasSearchBar || hasHamburger || hasAppIcon;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final statusBarStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshListings(visibleComponents),
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.primary,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (hasAppBar)
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: (hasHeader || hasAppIcon || hasHamburger || hasSearchBar) ? 240.h : 56.h,
                collapsedHeight: 48,
                toolbarHeight: 48,
                backgroundColor: scaffoldBg,
                surfaceTintColor: scaffoldBg,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 0),
                  title: hasSearchBar
                      ? Container(
                          height: 48,
                          alignment: Alignment.center,
                          child: HomeSearchBar(tabSlug: widget.tabSlug ?? ''),
                        )
                      : null,
                  background: hasHeader
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 36.h),
                          child: HomeHeaderImage(
                            imageUrl: headerImageComponent.image!,
                            logoUrl: appIconComponent.image,
                            onHamburgerTap: hasHamburger
                                ? () => drawerScaffoldKey.currentState?.openDrawer()
                                : null,
                          ),
                        )
                      : (hasAppIcon || hasHamburger || hasSearchBar)
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 36.h),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.elliptical(40.w, 12.h),
                                  bottomRight: Radius.elliptical(40.w, 12.h),
                                ),
                                child: HomeHeaderImage(
                                  imageUrl: '',
                                  logoUrl: appIconComponent.image,
                                  onHamburgerTap: hasHamburger
                                      ? () => drawerScaffoldKey.currentState?.openDrawer()
                                      : null,
                                ),
                              ),
                            )
                          : null,
                ),
              ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -12.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildBodyComponents(visibleComponents),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
      ),
    );
  }

  Future<void> _refreshListings(List<ContentSliderConfig> components) async {
    await ref.read(homeControllerProvider.notifier).refresh();

    final freshComponents = ref.read(homeControllerProvider).components;
    final futures = <Future>[];

    for (final c in freshComponents) {
      switch (c.variant) {
        case HomeScreenConstant.contentSliderV4:
          final key = c.id ?? c.variant.value;
          futures.add(ref.read(serviceControllerProvider(key).notifier).refresh());
          break;
        case HomeScreenConstant.contentSliderV5:
        case HomeScreenConstant.subCategorySlider:
          final key = c.category?.isNotEmpty == true ? c.category! : c.label ?? c.variant.value;
          final filter = ListingFilterModel(subcategorySlug: c.category, limit: c.limit ?? 10);
          futures.add(ref.read(listingControllerProvider(key).notifier).getListing(filter));
          break;
        default:
          break;
      }
    }

    await Future.wait(futures);
  }

  List<Widget> _buildBodyComponents(List<ContentSliderConfig> components) {
    final widgets = <Widget>[];
    bool isFirst = true;

    for (final component in components) {
      switch (component.variant) {
        case HomeScreenConstant.hamburgerMenu:
        case HomeScreenConstant.appiconImage:
        case HomeScreenConstant.headerImage:
        case HomeScreenConstant.searchBar:
          break;

        case HomeScreenConstant.contentSliderV4:
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(ContentSliderV4(config: component, tabSlug: widget.tabSlug ?? ''));
          widgets.add(18.verticalSpace);
          isFirst = false;
          break;

        case HomeScreenConstant.contentSliderV5:
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(ContentSliderV5(config: component));
          widgets.add(16.verticalSpace);
          isFirst = false;
          break;

        case HomeScreenConstant.subCategorySlider:
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(SubCategorySlider(config: component, tabSlug: widget.tabSlug ?? ''));
          widgets.add(18.verticalSpace);
          isFirst = false;
          break;

        case HomeScreenConstant.contentSliderV6:
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(ContentSliderV6(config: component));
          widgets.add(18.verticalSpace);
          isFirst = false;
          break;

        case HomeScreenConstant.tileSlider:
          final items = component.items ?? const [];
          if (items.isEmpty) break;
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(TileSliderCarousel(label: component.label, items: items));
          widgets.add(18.verticalSpace);
          isFirst = false;
          break;

        case HomeScreenConstant.serviceHubCard:
          if (isFirst) widgets.add(SizedBox(height: 22.h));
          widgets.add(_ServiceHubCard(config: component));
          widgets.add(18.verticalSpace);
          isFirst = false;
          break;
      }
    }

    if (widgets.isNotEmpty && widgets.last is SizedBox) {
      widgets.removeLast();
    }

    return widgets;
  }
}

class _ServiceHubCard extends ConsumerStatefulWidget {
  final ContentSliderConfig config;

  const _ServiceHubCard({required this.config});

  @override
  ConsumerState<_ServiceHubCard> createState() => _ServiceHubCardState();
}

class _ServiceHubCardState extends ConsumerState<_ServiceHubCard> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.config.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final label = widget.config.label ?? '';
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: CommonText(
              titleText: label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Stack(
            children: [
              SizedBox(
                height: 400.h,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    Color labelBgColor = theme.colorScheme.secondary;
                    final hex = item.titleBackgroundColor;
                    if (hex != null && hex.isNotEmpty) {
                      try {
                        labelBgColor = Color(int.parse(hex.replaceFirst('#', '0xff')));
                      } catch (_) {}
                    }
                    final itemLabel = item.label ?? '';
                    final hasImage = (item.image ?? '').isNotEmpty;

                    return GestureDetector(
                      onTap: item.action == null
                          ? null
                          : () => ref
                              .read(templateAHandlerProvider)
                              .executeAction(context, item.action!, title: itemLabel),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: hasImage
                                  ? CommonImage(
                                      imagePath: item.image!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: labelBgColor.withValues(alpha: 0.6)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, bottom: 4.h, right: 40.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (itemLabel.isNotEmpty)
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: labelBgColor,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (item.icon != null && item.icon!.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(right: 8.w),
                                              child: CommonImage(
                                                imagePath: item.icon!,
                                                height: 22.h,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Padding(
                                              padding: EdgeInsets.only(right: 6.w),
                                              child: Icon(Icons.card_giftcard, size: 20.sp, color: Colors.white),
                                            ),
                                          Flexible(
                                            child: CommonText(
                                              titleText: itemLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (items.length > 1)
                Positioned(
                  top: 10.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(items.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 8.h,
                        width: 8.w,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
