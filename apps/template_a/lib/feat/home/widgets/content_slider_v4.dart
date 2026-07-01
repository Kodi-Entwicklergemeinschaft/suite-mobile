import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/core/utils/string_extensions.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/home/data/models/tile_item.dart';
import 'package:template_a/feat/home/widgets/activity_card.dart';
import 'package:template_a/feat/services/data/models/service_response_model.dart';
import 'package:template_a/feat/services/presentation/controller/service_controller.dart';

class ContentSliderV4 extends BaseStatefulWidget {
  final ContentSliderConfig config;
  final String tabSlug;

  const ContentSliderV4({super.key, required this.config, required this.tabSlug});

  @override
  ConsumerState<ContentSliderV4> createState() => _ContentSliderV4State();
}

class _ContentSliderV4State extends BaseStatefulWidgetState<ContentSliderV4> {
  final PageController _controller = PageController(viewportFraction: 1);
  int _currentPage = 0;

  String get _providerKey => widget.config.id ?? widget.config.variant.value;

  // True when the CMS provides inline items — no service API needed
  bool get _hasInlineItems =>
      widget.config.items != null && widget.config.items!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });

    if (!_hasInlineItems) {
      // Legacy path: fetch from service API when no inline items provided
      final actionType = widget.config.action?.type;
      final shouldFetch = actionType == null || actionType == 'category';
      if (shouldFetch) {
        Future.microtask(() {
          ref.read(serviceControllerProvider(_providerKey).notifier).fetchServices(
            limit: 20,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(BuildContext context, ActionResponseModel action, String? title) {
    ref.read(templateAHandlerProvider).executeAction(context, action, title: title);
  }

  bool _shouldShow(bool isGuest, {bool? requireLogin, bool? isGuestOnly}) {
    final login = requireLogin ?? false;
    final guestOnly = isGuestOnly ?? false;
    if (login && !guestOnly) return !isGuest;  // logged-in only
    if (!login && guestOnly) return isGuest;   // guest only
    return true;                               // both false → show for everyone
  }

  bool _shouldShowServiceItem(ServiceResponseModel item, bool isGuest) {
    if (item.action?.config?.isVisible == false) return false;
    return _shouldShow(
      isGuest,
      requireLogin: item.action?.config?.requireLogin,
      isGuestOnly: item.action?.config?.isGuestOnly,
    );
  }

  bool _shouldShowTileItem(TileItem item, bool isGuest) {
    if (item.action?.config?.isVisible == false) return false;
    return _shouldShow(
      isGuest,
      requireLogin: item.action?.config?.requireLogin,
      isGuestOnly: item.action?.config?.isGuestOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Inline items from CMS (new path) ─────────────────────────────────────
    if (_hasInlineItems) {
      final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
      final filteredItems = widget.config.items!
          .where((item) => _shouldShowTileItem(item, isGuest))
          .toList();
      if (filteredItems.isEmpty) return const SizedBox.shrink();
      return _buildSlider(
        context,
        theme,
        items: filteredItems,
      );
    }

    // ── Single direct-action card (no carousel, no API) ───────────────────────
    final actionType = widget.config.action?.type;
    final isDirectAction = actionType != null && actionType != 'category';
    if (isDirectAction) {
      final color = widget.config.titleBackgroundColor != null
          ? Color(int.tryParse(widget.config.titleBackgroundColor!.replaceFirst('#', '0xff')) ?? 0xFF000000)
          : theme.colorScheme.secondary;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.config.label != null && widget.config.label!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: CommonText(
                  titleText: widget.config.label!,
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
            SizedBox(
              height: 400.h,
              child: GestureDetector(
                onTap: () {
                  final a = widget.config.action!;
                  _onItemTap(
                    context,
                    ActionResponseModel().fromJson(a.toJson()),
                    widget.config.title ?? widget.config.label,
                  );
                },
                child: ActivityCard(
                  imageUrl: widget.config.image ?? '',
                  tagText: widget.config.title,
                  tagIconPath: widget.config.icon,
                  tagBgColor: color,
                  title: widget.config.description,
                  titleBgColor: color,
                  subtitle: null,
                  subtitleBgColor: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Legacy path: items from service API ───────────────────────────────────
    final serviceState = ref.watch(serviceControllerProvider(_providerKey));
    final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);
    final allServiceItems = serviceState.services;
    final serviceItems = allServiceItems
        .where((item) => _shouldShowServiceItem(item, isGuest))
        .toList();

    if (serviceState.configState != StateConstant.loading && allServiceItems.isNotEmpty && serviceItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null && widget.config.label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: CommonText(
              titleText: widget.config.label!,
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
        if (serviceState.configState == StateConstant.loading)
          _buildShimmer()
        else if (serviceItems.isEmpty)
          SizedBox(
            height: 60.h,
            child: Center(
              child: CommonText(
                titleText: 'no_data'.tr,
                textStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            ),
          )
        else
          _buildServiceSlider(context, theme, serviceItems),
      ],
    );
  }

  // Builds the carousel from inline CMS items (TileItem list)
  Widget _buildSlider(BuildContext context, ThemeData theme, {required List<TileItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.label != null && widget.config.label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: CommonText(
              titleText: widget.config.label!,
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
                    final tagBgColor = item.titleBackgroundColor.isNotNullAndEmpty
                        ? item.titleBackgroundColor!.hexToColor
                        : theme.colorScheme.secondary;

                    return Semantics(
                      button: item.action != null,
                      label: item.label ?? '',
                      child: GestureDetector(
                        onTap: item.action != null
                            ? () => _onItemTap(context, item.action!, item.label)
                            : null,
                        child: ActivityCard(
                          imageUrl: item.image ?? '',
                          tagText: item.label,
                          tagIconPath: item.icon,
                          tagBgColor: tagBgColor,
                          title: item.subtitle,
                          titleBgColor: tagBgColor,
                          subtitle: item.description,
                          subtitleBgColor: theme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildPageIndicator(items.length),
            ],
          ),
        ),
      ],
    );
  }

  // Builds the carousel from legacy service API items
  Widget _buildServiceSlider(
    BuildContext context,
    ThemeData theme,
    List<ServiceResponseModel> items,
  ) {
    return Padding(
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
                final titleBgColor = item.titleBackgroundColor.isNotNullAndEmpty
                    ? item.titleBackgroundColor.hexToColor
                    : theme.colorScheme.secondary;

                return Semantics(
                  button: true,
                  label: item.title ?? item.label ?? '',
                  child: GestureDetector(
                    onTap: () {
                      if (item.action != null) {
                        _onItemTap(context, item.action!, item.title ?? item.label);
                      }
                    },
                    child: ActivityCard(
                      imageUrl: item.serviceImage ?? '',
                      tagText: item.title,
                      tagIconPath: item.icon,
                      tagBgColor: titleBgColor,
                      title: item.subtitle,
                      titleBgColor: titleBgColor,
                      subtitle: item.description,
                      subtitleBgColor: theme.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          _buildPageIndicator(items.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Positioned(
      top: 10.h,
      left: 0,
      right: 0,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ShimmerWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 400.h,
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
                  height: 36.h,
                  width: 220.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
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
                  height: 36.h,
                  width: 180.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
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
    );
  }
}
