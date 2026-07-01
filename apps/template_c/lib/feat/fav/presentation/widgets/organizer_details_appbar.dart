import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/core/widgets/app_back_button.dart';
import 'package:template_c/feat/organizer/controller/organizer_detail_controller.dart';

class OrganizerDetailsAppbar extends BaseStatelessWidget implements PreferredSizeWidget {
  final String id;

  const OrganizerDetailsAppbar({super.key, required this.id});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(organizerDetailControllerProvider(id)).detail;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 18.w,
      centerTitle: true,
      leadingWidth: 40.w,
      leading: const AppBackButton(),
      title: CommonText(
        titleText: 'organizer_detail_appbar_title'.tr,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => shareEvent(
            title: detail?.displayName ?? detail?.username ?? '',
            address: detail?.address,
            websiteUrl: detail?.website,
            context: context,
          ),
          child: isDark
              ? SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_dark.svg',
                  width: 32.w,
                  height: 32.h,
                )
              : SvgPicture.asset(
                  'assets/svg/listing_details_share_icon_light.svg',
                  width: 32.w,
                  height: 32.h,
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
