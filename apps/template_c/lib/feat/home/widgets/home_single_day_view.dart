import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/widgets/banner_widget.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/home/widgets/listing/listing_widget.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';

class HomeSingleDayView extends BaseStatelessWidget {
  final String filterKey;
  final String sectionTitle;
  final String actionLabel;
  final DateTime dateFrom;
  final DateTime dateTo;
  

  const HomeSingleDayView({
    super.key,
    required this.filterKey,
    required this.sectionTitle,
    required this.actionLabel,
    required this.dateFrom,
    required this.dateTo,
    
  });

  /// Today — dates resolved at build time so it stays correct across midnight
  static HomeSingleDayView today() {
    final date = DateTime.now();
    return HomeSingleDayView(
      key: const ValueKey('heute'),
      filterKey: 'heute',
      sectionTitle: 'home_today_events'.tr,
      actionLabel: formatTabDate(date),
      dateFrom: DateTime(date.year, date.month, date.day, 00, 00, 00),
      dateTo: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
  }

  /// Tomorrow
  static HomeSingleDayView tomorrow() {
    final date = DateTime.now().add(const Duration(days: 1));
    return HomeSingleDayView(
      key: const ValueKey('morgen'),
      filterKey: 'morgen',
      sectionTitle: 'home_tomorrow_events'.tr,
      actionLabel: formatTabDate(date),
      dateFrom: DateTime(date.year, date.month, date.day, 00, 00, 00),
      dateTo: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
  }

  /// Custom date range from calendar picker
  static HomeSingleDayView customRange(DateTimeRange range) {
    final from = range.start;
    final to = range.end;
    String pad(int n) => n.toString().padLeft(2, '0');
    final key =
        'custom_${from.year}${pad(from.month)}${pad(from.day)}'
        '_${to.year}${pad(to.month)}${pad(to.day)}';
    return HomeSingleDayView(
      key: ValueKey(key),
      filterKey: key,
      sectionTitle: 'home_all_events'.tr,
      actionLabel: '${formatTabDate(from)} – ${formatTabDate(to)}',
      dateFrom: DateTime(from.year, from.month, from.day, 00, 00, 00),
      dateTo: DateTime(to.year, to.month, to.day, 23, 59, 59),
    );
  }

  String get _familyKey => ListingFamilyKey.dayEvents(filterKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(listingControllerProvider(_familyKey).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            ListingWidget(
              key: ValueKey(filterKey),
              variant: HomeScreenConstant.contentSliderV2,
              filterKey: filterKey,
              initialFilter: ListingFilterModel(
                limit: 10,
                eventStartFrom: dateFrom,
                eventStartTo: dateTo,
                requireLatLong: true,
              ),
              sectionTitle: sectionTitle,
              actionLabel: actionLabel,
              showActionChevron: false,
              scrollDirection: Axis.vertical,
              maxItems: 10,
              injectAtIndex: 2,
              injectWidget: HeadlineBannerWidget(onActionTap: () {}, fallbackHeight: 24.h),
              isSeeAllButton: true,
            ),
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }
}
