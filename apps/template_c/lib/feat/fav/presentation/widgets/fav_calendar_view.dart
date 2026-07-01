import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:go_router/go_router.dart';
import 'package:template_c/core/widgets/dot_indicator_calendar.dart';
import 'package:template_c/feat/fav/controller/fav_controller.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/router/route_constant.dart';

class FavCalendarView extends BaseStatefulWidget {
  const FavCalendarView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavCalendarViewState();
}

class _FavCalendarViewState extends BaseStatefulWidgetState<FavCalendarView> {
  String familyKey = 'FavCalnedarView';
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      final state = ref.read(favScreenControllerProvider);

      ref
          .read(favScreenControllerProvider.notifier)
          .getMonthFavListingDate(
            startDate: DateTime(
              state.selectedDate.year,
              state.selectedDate.month,
              1,
              0,
              0,
              0,
            ),
            endDate: DateTime(
              state.selectedDate.year,
              state.selectedDate.month + 1,
              0,
              23,
              59,
              59,
            ),
          );
      ref
          .read(favScreenControllerProvider.notifier)
          .getCalendarViewFavListing();
    });
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(favScreenControllerProvider.notifier).loadMoreCalendarViewFav();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favScreenControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarOverlay(context),
              48.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonText(
                  titleText: formatSelectedDate(state.selectedDate),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ),

              20.verticalSpace,

              if (state.calendarViewStateConstant == StateConstant.loading)
                Center(child: CircularProgressIndicator()),

              if (state.calendarViewStateConstant == StateConstant.success &&
                  state.calendarViewListOfFav.isEmpty)
                Center(
                  child: CommonText(
                    titleText: 'no_data'.tr,
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (state.calendarViewStateConstant == StateConstant.success &&
                  state.calendarViewListOfFav.isNotEmpty)
                _buildList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarOverlay(BuildContext context) {
    final state = ref.watch(favScreenControllerProvider);

    final controller = ref.read(favScreenControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 28.r,
                ),
                Expanded(
                  child: Center(
                    child: CommonText(
                      titleText: 'monthly_plan'.tr,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
                48.horizontalSpace,
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w),
          child: DotIndicatorCalendar(
            dotDates: state.dateList
                .map((element) => DateTime.parse(element))
                .toList(),
            dotColor: Theme.of(context).colorScheme.secondary,
            selectedDayColor: Theme.of(context).colorScheme.secondary,
            onDateTap: (dateTime) async {
              await controller.updateSelectedDate(dateTime);
            },
            initialDate: state.selectedDate,
            onMonthChange: (DateTime startDate, DateTime endDate) async {
              await controller.getMonthFavListingDate(
                startDate: startDate,
                endDate: endDate,
              );
            },
          ),
        ),
      ],
    );
  }

  _buildList(BuildContext context) {
    final state = ref.watch(favScreenControllerProvider);

    final itemCount =
        state.calendarViewListOfFav.length +
        (state.calendarViewHasNextPage ? 1 : 0);

    return Container(
      height: 120.h,
      width: double.infinity,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == state.calendarViewListOfFav.length) {
            return Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final item = state.calendarViewListOfFav[index];
          return SizedBox(
            width: 350.w,
            child: ListingItemCard.compact(
              model: item,
              onTap: item.id == null
                  ? null
                  : () {
                      context.pushNamed(
                        RouteConstant.listingDetail.name,
                        pathParameters: {'id': item.id!},
                        queryParameters: {'familyKey': familyKey},
                      );
                    },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return 8.horizontalSpace;
        },
      ),
    );
  }
}
