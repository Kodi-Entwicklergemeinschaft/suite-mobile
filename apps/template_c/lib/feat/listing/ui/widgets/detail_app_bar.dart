import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/widgets/app_back_button.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/listing/controller/listing_detail_controller.dart';

class DetailAppBar extends BaseStatelessWidget implements PreferredSizeWidget {
  final ({String id, String familyKey}) providerKey;

  const DetailAppBar({super.key, required this.providerKey});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref
        .watch(listingDetailControllerProvider(providerKey))
        .listing;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 18.w,
      centerTitle: true,
      leadingWidth: 40.w,
      leading: const AppBackButton(),
      title: CommonText(
        // titleText: 'listing_event'.tr,
        titleText: listing?.categoryTitle ?? '',
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => shareEvent(
            title: listing?.title ?? '',
            dateLine: formatEventDateFull(listing?.eventStart),
            address: listing?.address,
            websiteUrl: listing?.website,
          ),
          child: isDark
              ? SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_dark.svg',
                  width: 32.w,
                  height: 32.h,
                  // colorFilter: ColorFilter.mode(
                  //   Theme.of(context).colorScheme.surface,
                  //   BlendMode.srcIn,
                  // ),
                )
              : SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_light.svg',
                  width: 32.w,
                  height: 32.h,
                  // colorFilter: ColorFilter.mode(
                  //   Theme.of(context).colorScheme.surface,
                  //   BlendMode.srcIn,
                  // ),
                ),
        ),
        SizedBox(width: 18.w),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1),
      ),
    );
  }
}
