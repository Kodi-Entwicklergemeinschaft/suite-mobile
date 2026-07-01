import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/utils/listing_utils.dart';
import 'package:template_c/feat/fav/presentation/organizer_detail_screen.dart';
import 'package:template_c/feat/organizer/data/models/organizer_model.dart';
import 'package:template_c/feat/organizer/controller/organizer_follow_toggle_controller.dart';

class DetailOrganizerWidget extends BaseStatefulWidget {
  final OrganizerModel organizer;
  final bool? initiallySubscribed;
  final VoidCallback? onOrganizerTap;
  final ValueChanged<bool>? onSubscribeChanged;

  const DetailOrganizerWidget({
    super.key,
    required this.organizer,
    this.initiallySubscribed,
    this.onOrganizerTap,
    this.onSubscribeChanged,
  });

  @override
  ConsumerState<DetailOrganizerWidget> createState() =>
      _DetailOrganizerWidgetState();
}

class _DetailOrganizerWidgetState extends BaseStatefulWidgetState<DetailOrganizerWidget> {
  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(organizerSubscriptionsProvider);
    final organizerId = widget.organizer.id;
    final organizerName =
        widget.organizer.displayName ?? widget.organizer.username ?? '';
    if (organizerName.isEmpty) return const SizedBox.shrink();

    final _subscribed = subscriptions[organizerId] ?? widget.organizer.isFollowing ?? false;

    final initials = nameInitials(organizerName);
    final theme = Theme.of(context);
    final appColors = ref.watch(appThemeProvider).colors;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = appColors.getTextColor(isDark);
    final primaryColor = appColors.primary;
    final dividerColor = theme.dividerTheme.color ?? theme.dividerColor;
    final logoUrl = widget.organizer.avatar;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
    final summary = widget.organizer.summary ?? widget.organizer.username;
    final organizerTap =
        widget.onOrganizerTap ??
        (organizerId?.isNotEmpty == true
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrganizerDetailScreen(
                    id: organizerId!,
                    name: organizerName,
                    category: summary,
                    logoUrl: logoUrl,
                    initiallySubscribed: _subscribed,
                  ),
                ),
              )
            : null);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: 'listing_detail_organizer'.tr,
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: context.templateColors.surfaceBg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: dividerColor, width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x14000000),
                  offset: Offset(0, 8.h),
                  blurRadius: 54.r,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: organizerTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: context.templateColors.chipBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: dividerColor, width: 1.w),
                          ),
                          child: ClipOval(
                            child: hasLogo
                                ? CommonImage(
                                    imagePath: logoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: CommonText(
                                      titleText: initials.isEmpty
                                          ? organizerName[0].toUpperCase()
                                          : initials,
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                titleText: organizerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: textColor,
                                ),
                              ),
                              if (summary?.isNotEmpty == true) ...[
                                SizedBox(height: 4.h),
                                CommonText(
                                  titleText: summary ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.sp,
                                    color: theme
                                        .extension<AppTextColors>()!
                                        .inverse,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      titleText: _subscribed
                          ? 'organizer_subscribed'.tr
                          : 'listing_detail_organizer_subscribe'.tr,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CommonSwitchToggle(
                      value: _subscribed,
                      onChanged: (val) async {
                        if (widget.onSubscribeChanged != null) {
                          widget.onSubscribeChanged!(val);
                          return;
                        }
                        if (organizerId?.isNotEmpty == true) {
                          await ref
                              .read(organizerToggleControllerProvider)
                              .toggle(organizerId!, subscribe: val);
                        }
                      },
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
