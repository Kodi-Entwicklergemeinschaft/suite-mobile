import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/common_enums.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/feat/home/constants/home_screen_constant.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/home/widgets/banner_widget.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/home/widgets/listing/listing_widget.dart';
import 'package:template_c/feat/listing/controller/listing_controller.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';

class HomeWeekView extends BaseStatelessWidget {
  const HomeWeekView({super.key});

  String _familyKey(String filterKey) => ListingFamilyKey.dayEvents(filterKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final pref = ref.read(preferenceManagerProvider);
    final isBannerVisible =
        pref.getStringOrEmpty(StorageKeys.authRole) == UserRole.guest.value &&
        !ref.watch(homeControllerProvider).isConfigLoading;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          for (final day in HomeWeekDay.values)
            ref
                .read(listingControllerProvider(_familyKey(day.filterKey)).notifier)
                .refresh(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            for (final day in HomeWeekDay.values) ...[
              ListingWidget(
                key: ValueKey(day.filterKey),
                variant: HomeScreenConstant.contentSliderV2,
                filterKey: day.filterKey,
                initialFilter:
                    _dayFilter(monday.add(Duration(days: day.dayOffset))),
                sectionTitle:
                    '${'home_events_on'.tr} ${'home_weekday_${day.filterKey}'.tr}',
                actionLabel: formatTabDate(monday.add(Duration(days: day.dayOffset))),
                showActionChevron: false,
                scrollDirection: Axis.horizontal,
                isSeeAllButton: true,
              ),
              if (day == HomeWeekDay.monday) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: HeadlineBannerWidget(onActionTap: () {}),
                ),
                if (!isBannerVisible) Divider(thickness: 8.h, height: 120.h),
              ] else if (day != HomeWeekDay.values.last)
                Divider(thickness: 8.h, height: 120.h),
            ],
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  ListingFilterModel _dayFilter(DateTime day) {
    return ListingFilterModel(
      limit: 10,
      eventStartFrom: DateTime(day.year, day.month, day.day, 00, 00, 00),
      eventStartTo: DateTime(day.year, day.month, day.day, 23, 59, 59),
      requireLatLong: true,
    );
  }
}
