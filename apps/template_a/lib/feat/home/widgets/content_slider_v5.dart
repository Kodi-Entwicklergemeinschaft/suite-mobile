import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/feat/category/presentation/category_screen.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/listing/data/models/listing_model.dart';
import 'package:template_a/feat/listing/presentation/listing_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/state_constant.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/widgets/register_dialog.dart';
import 'package:template_a/core/widgets/shimmer_widget.dart';
import 'package:template_a/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_a/feat/home/constants/home_screen_constant.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/listing/controller/listing_controller.dart';
import 'package:template_a/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_a/feat/home/widgets/event_card.dart';
import 'package:template_a/router/router_provider.dart'
    show shellConfigProvider;

class ContentSliderV5 extends BaseStatefulWidget {
  final ContentSliderConfig config;

  const ContentSliderV5({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<ContentSliderV5> createState() => _ContentSliderV5State();
}

class _ContentSliderV5State extends BaseStatefulWidgetState<ContentSliderV5> {
  static const _viewVertical = 'vertical';

  String get _familyKey => widget.config.category?.isNotEmpty == true
      ? widget.config.category!
      : widget.config.label ?? HomeScreenConstant.contentSliderV5.value;

  ListingFilterModel get _filter => ListingFilterModel(
        subcategorySlug: widget.config.category,
        limit: widget.config.limit ?? 10,
      );

  @override
  void initState() {
    super.initState();
    _scheduleFetch();
  }

  @override
  void didUpdateWidget(ContentSliderV5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.category != widget.config.category) {
      _scheduleFetch();
    }
  }

  void _scheduleFetch() {
    final actionType = widget.config.action?.type;
    final shouldFetch = actionType == null || actionType == 'category';
    if (shouldFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(listingControllerProvider(_familyKey).notifier).getListing(_filter);
        }
      });
    }
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null || start.isEmpty) return '';
    try {
      final s = DateTime.parse(start).toLocal();
      final startDate = DateFormat('dd.MM.yyyy').format(s);
      final startTime = DateFormat('HH:mm').format(s);
      if (end == null || end.isEmpty) return '$startDate · $startTime';
      final e = DateTime.parse(end).toLocal();
      final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
      final endTime = DateFormat('HH:mm').format(e);
      if (sameDay) return '$startDate · $startTime – $endTime';
      final endDate = DateFormat('dd.MM.yyyy').format(e);
      return '$startDate · $startTime ${'to'.tr} $endDate – $endTime';
    } catch (_) {
      return '';
    }
  }

  void _onItemTap(BuildContext context, ListingModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: item)),
    );
  }

  void _onFavTap(BuildContext context, String listingId, bool currentlyFav) {
    if (listingId.isEmpty) return;
    final prefs = ref.read(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;

    if (!isFullyLoggedIn) {
      showRegisterDialog(context, ref);
    } else {
      ref.read(favouriteToggleServiceProvider).toggleFav(
        id: listingId,
        newValue: !currentlyFav,
      );
    }
  }

  // void _onSeeAllTap(BuildContext context) {
  //   context.pushNamed(
  //     RouteConstant.listing.name,
  //     extra: ListingScreenParams(
  //       familyKey: 'see_all_$_familyKey',
  //       screenTitle: widget.config.label ?? 'listing'.tr,
  //       initialFilter: _filter.copyWith(page: 1, limit: 20),
  //     ),
  //   );
  // }

  void _onSeeAllTap(BuildContext context) {
    final action = widget.config.action;

    // If component has an explicit action, use the handler
    if (action != null && action.type != null) {
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
        title: widget.config.label,
      );
      return;
    }

    // Default: navigate to category/tab
    final category = widget.config.category ?? '';
    final tabs = ref.read(shellConfigProvider) ?? [];
    final matchIndex = tabs.indexWhere(
      (t) => t.action?.config?.category == category,
    );

    if (matchIndex != -1) {
      StatefulNavigationShell.of(context).goBranch(matchIndex);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryScreen(
            params: CategoryScreenParams(
              categorySlug: category,
              screenTitle: widget.config.label ?? '',
            ),
          ),
        ),
      );
    }
  }

  bool get _isVertical => widget.config.action?.config?.view == _viewVertical;

  bool get _isDirectAction {
    final actionType = widget.config.action?.type;
    return actionType != null && actionType != 'category';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Non-category type — show single card same as normal V5 card size
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
                textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10.h),
            ],
            EventCard(
              imageUrl: widget.config.image ?? '',
              title: widget.config.title ?? widget.config.label ?? '',
              dateRange: widget.config.description ?? '',
              bgColor: widget.config.titleBackgroundColor != null
                  ? Color(int.tryParse(widget.config.titleBackgroundColor!.replaceFirst('#', '0xff')) ?? 0xFF000000)
                  : theme.colorScheme.secondary,
              onTap: () => _onSeeAllTap(context),
            ),
          ],
        ),
      );
    }

    final state = ref.watch(listingControllerProvider(_familyKey));

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
          if (state.stateConstant == StateConstant.loading)
            _isVertical
                ? ShimmerWidget(
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // image area
                              Container(
                                height: 100.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 12.h, width: 100.w, color: Colors.white),
                                    SizedBox(height: 6.h),
                                    Container(height: 14.h, width: 160.w, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : ShimmerWidget(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          4,
                          (_) => Container(
                            width: 160.w,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // image area
                                Container(
                                  height: 100.h,
                                  width: double.infinity,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(height: 11.h, width: 80.w, color: Colors.white),
                                      SizedBox(height: 4.h),
                                      Container(height: 13.h, width: 120.w, color: Colors.white),
                                      SizedBox(height: 6.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
          else if (state.stateConstant == StateConstant.error)
            SizedBox(
              height: 60.h,
              child: Center(
                child: CommonText(
                  titleText: 'error_loading'.tr,
                  textStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ),
            )
          else if (state.listingModel.isEmpty)
            SizedBox(
              height: 60.h,
              child: Center(
                child: CommonText(
                  titleText: 'no_data'.tr,
                  textStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ),
            )
          else if (_isVertical)
            Column(
              children: [
                for (final item in state.listingModel)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: EventCard(
                      title: item.title ?? '',
                      dateRange: _formatDateRange(item.eventStart, item.eventEnd),
                      imageUrl: item.firstImageUrl ?? '',
                      fallbackImageUrl: item.categoryFallbackImage,
                      bgColor: theme.colorScheme.secondary,
                      isFavourite: item.isFavourite,
                      onTap: () => _onItemTap(context, item),
                      onTapOnFavourite: () => _onFavTap(context, item.id ?? '', item.isFavourite),
                    ),
                  ),
                Semantics(
                  button: true,
                  label: 'see_all'.tr,
                  child: GestureDetector(
                  onTap: () => _onSeeAllTap(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Center(
                      child: ExcludeSemantics(
                        child: CommonText(
                          titleText: 'see_all'.tr,
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < state.listingModel.length && i < 4; i++)
                    EventCard(
                      title: state.listingModel[i].title ?? '',
                      dateRange: _formatDateRange(state.listingModel[i].eventStart, state.listingModel[i].eventEnd),
                      imageUrl: state.listingModel[i].firstImageUrl ?? '',
                      fallbackImageUrl: state.listingModel[i].categoryFallbackImage,
                      bgColor: theme.colorScheme.secondary,
                      isFavourite: state.listingModel[i].isFavourite,
                      onTap: () => _onItemTap(context, state.listingModel[i]),
                      onTapOnFavourite: () => _onFavTap(
                        context,
                        state.listingModel[i].id ?? '',
                        state.listingModel[i].isFavourite,
                      ),
                    ),
                  _ShowMoreButton(onTap: () => _onSeeAllTap(context)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ShowMoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'show_all'.tr,
      child: InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 190.h,
        child: ExcludeSemantics(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 22.h,
                color: theme.colorScheme.surface,
              ),
            ),
            SizedBox(height: 8.h),
            CommonText(
              titleText: 'show_all'.tr,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        ),
      ),
      ),
    );
  }
}
