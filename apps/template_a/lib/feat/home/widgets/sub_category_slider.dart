import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/category/controller/category_screen_controller.dart';
import 'package:template_a/feat/category/data/models/category_filter_model.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/home/data/models/tile_item.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';
class SubCategorySlider extends BaseStatefulWidget {
  final ContentSliderConfig config;
  final String tabSlug;

  const SubCategorySlider({
    super.key,
    required this.config,
    required this.tabSlug,
  });

  @override
  ConsumerState<SubCategorySlider> createState() => _SubCategorySliderState();
}

class _SubCategorySliderState extends BaseStatefulWidgetState<SubCategorySlider> {
  String get _categorySlug => widget.config.category ?? '';

  @override
  void initState() {
    super.initState();
    _scheduleFetch();
  }

  @override
  void didUpdateWidget(SubCategorySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.category != widget.config.category) {
      _scheduleFetch();
    }
  }

  void _scheduleFetch() {
    final actionType = widget.config.action?.type;
    final isDirectAction = actionType != null && actionType != 'category';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _categorySlug.isEmpty || isDirectAction) return;
      ref
          .read(categoryScreenControllerProvider(_categorySlug).notifier)
          .loadCategory();
    });
  }

  bool _shouldShowItem(TileItem item, bool isGuest) {
    if (item.action?.config?.isVisible == false) return false;
    final login = item.requireLogin ?? false;
    final guestOnly = item.action?.config?.isGuestOnly ?? false;
    if (login && !guestOnly) return !isGuest;
    if (!login && guestOnly) return isGuest;
    return true;
  }

  void _onItemTap(BuildContext context, TileItem item) {
    final actionJson = <String, dynamic>{
      'type': item.actionType,
      'target': item.actionTarget,
      'config': {
        'url': item.actionUrl,
        'requireLogin': item.requireLogin,
        'requireShortCode': item.requireShortCode,
      },
    };
    final actionModel = ActionResponseModel().fromJson(actionJson);
    ref.read(templateAHandlerProvider).executeAction(context, actionModel, title: item.label);
  }

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  void _navigateToCategory(BuildContext context, CategoryScreenParams params) {
    context.push('/shell/${widget.tabSlug}/category', extra: params);
  }

  void _openParentCategoryScreen(BuildContext context, String? titleBackgroundColor, {String? preSelectedFilter}) {
    if (_categorySlug.isEmpty) return;
    _navigateToCategory(
      context,
      CategoryScreenParams(
        categorySlug: _categorySlug,
        screenTitle: widget.config.label ?? '',
        headerColorHex: titleBackgroundColor,
        preSelectedFilter: preSelectedFilter,
      ),
    );
  }

  void _openChildCategoryScreen(BuildContext context, CategoryChild child, String? titleBackgroundColor) {
    if (child.slug.isEmpty) return;
    _navigateToCategory(
      context,
      CategoryScreenParams(
        categorySlug: _categorySlug,
        screenTitle: widget.config.label ?? '',
        preSelectedFilter: child.slug,
        headerColorHex: titleBackgroundColor,
      ),
    );
  }

  bool get _isDirectAction {
    final actionType = widget.config.action?.type;
    return actionType != null && actionType != 'category';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Direct action (url_webview, feature, url_browser) — always show single card
    if (_isDirectAction) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.config.label != null && widget.config.label!.isNotEmpty) ...[
              CommonText(
                titleText: widget.config.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10.h),
            ],
            SizedBox(
              height: 160.h,
              child: CommonImageTextCard(
                title: widget.config.title ?? widget.config.label ?? '',
                imageUrl: widget.config.image ?? '',
                titleColor: _parseColor(widget.config.titleBackgroundColor, theme.colorScheme.secondary),
                onTap: () {
                  final action = widget.config.action!;
                  final actionJson = <String, dynamic>{
                    'type': action.type,
                    'target': action.target,
                    'config': {
                      'url': action.config?.url,
                      'requireLogin': action.config?.requireLogin ?? false,
                      'requireShortCode': action.config?.requireShortCode ?? false,
                      'category': action.config?.category,
                    },
                  };
                  final actionModel = ActionResponseModel().fromJson(actionJson);
                  ref.read(templateAHandlerProvider).executeAction(
                    context,
                    actionModel,
                    title: widget.config.title ?? widget.config.label,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Items-based v6 (no category slug) — render directly from config.items
    if (_categorySlug.isEmpty) {
      final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
      final items = (widget.config.items ?? [])
          .where((item) => _shouldShowItem(item, isGuest))
          .toList();

      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              titleText: widget.config.label ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 160.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return CommonImageTextCard(
                    title: item.label ?? '',
                    imageUrl: item.image ?? '',
                    titleColor: _parseColor(item.titleBackgroundColor, theme.colorScheme.secondary),
                    onTap: item.actionType == null ? null : () => _onItemTap(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final categoryState = ref.watch(
      categoryScreenControllerProvider(_categorySlug),
    );

    final List<CategoryChild> allEnabled =
        (categoryState.category?.children ?? []).where((c) => c.enabled).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    final List<CategoryChild> quickFilters =
        allEnabled.where((c) => c.isQuickFilter).toList();
    final bool hasQuickFilters = quickFilters.isNotEmpty;
    final List<CategoryChild> subCategories =
        allEnabled.where((c) => !c.isQuickFilter).toList();

    // titleBackgroundColor from the parent category for card bg
    final Color cardBgColor = _parseColor(
      categoryState.category?.titleBackgroundColor,
      theme.colorScheme.secondary,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: widget.config.label ?? 'listing'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          if (categoryState.stateConstant == StateConstant.loading)
            ShimmerWidget(
              child: SizedBox(
                height: 160.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (_, __) => Container(
                    width: 160.w,
                    height: 160.h,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Stack(
                      children: [
                        // full image fill
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        // title chip at bottom-left (mirrors CommonImageTextCard)
                        Positioned(
                          bottom: 12.h,
                          left: 0,
                          child: Container(
                            height: 36.h,
                            width: 110.w,
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
              ),
            )
          else if (categoryState.stateConstant == StateConstant.error)
            SizedBox(
              height: 60.h,
              child: Center(
                child: CommonText(
                  titleText: 'error_loading'.tr,
                  textStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 160.h,
              child: hasQuickFilters
                  // API se quickFilters aaye → first QF + subcategories + last QF (see-all)
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickFilters.length + subCategories.length,
                      itemBuilder: (_, index) {
                        // first quickFilter (Nearby) — index 0
                        if (index == 0) {
                          final child = quickFilters.first;
                          return CommonImageTextCard(
                            title: child.title,
                            imageUrl: child.image ?? '',
                            titleColor: cardBgColor,
                            onTap: () => _openChildCategoryScreen(context, child, categoryState.category?.titleBackgroundColor),
                          );
                        }
                        // last quickFilter (See All) — last index
                        final lastIndex = quickFilters.length + subCategories.length - 1;
                        if (index == lastIndex && quickFilters.length > 1) {
                          final child = quickFilters.last;
                          return CommonImageTextCard(
                            title: child.title,
                            imageUrl: child.image ?? '',
                            titleColor: cardBgColor,
                            onTap: () => _openChildCategoryScreen(context, child, categoryState.category?.titleBackgroundColor),
                          );
                        }
                        // subcategories in between
                        final subIndex = index - 1;
                        if (subIndex < 0 || subIndex >= subCategories.length) {
                          return const SizedBox.shrink();
                        }
                        final child = subCategories[subIndex];
                        return CommonImageTextCard(
                          title: child.title,
                          imageUrl: child.image ?? '',
                          titleColor: cardBgColor,
                          onTap: () => _openChildCategoryScreen(context, child, categoryState.category?.titleBackgroundColor),
                        );
                      },
                    )
                  // quickFilters nahi → static Nearby + subcategories + See All
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subCategories.length + 2,
                      itemBuilder: (_, index) {
                        final isNearby = index == 0;
                        final isSeeAll = index == subCategories.length + 1;

                        if (isNearby) {
                          return CommonImageTextCard(
                            title: 'nearby'.tr,
                            imageUrl: 'assets/images/nearby.webp',
                            titleColor: cardBgColor,
                            onTap: () => _openParentCategoryScreen(context, categoryState.category?.titleBackgroundColor, preSelectedFilter: '__nearby__'),
                          );
                        }

                        if (isSeeAll) {
                          return CommonImageTextCard(
                            title: 'see_all'.tr,
                            imageUrl: 'assets/images/see_all.webp',
                            titleColor: cardBgColor,
                            onTap: () => _openParentCategoryScreen(context, categoryState.category?.titleBackgroundColor, preSelectedFilter: '__see_all__'),
                          );
                        }

                        final child = subCategories[index - 1];
                        return CommonImageTextCard(
                          title: child.title,
                          imageUrl: child.image ?? '',
                          titleColor: cardBgColor,
                          onTap: () => _openChildCategoryScreen(context, child, categoryState.category?.titleBackgroundColor),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
