import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locale/localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:template_c/core/feature_flags.dart';
import 'package:template_c/feat/handler/template_c_handler.dart';
import 'package:template_c/feat/legal/constant/legal_type.dart';
import 'package:template_c/feat/legal/controller/legal_controller.dart';
import 'package:template_c/feat/legal/model/response/legal_response_model.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_params.dart';
import 'package:template_c/router/route_constant.dart';

import 'package:theme/theme.dart';
import 'package:template_c/feat/home/controller/home_controller.dart';
import 'package:template_c/feat/profile/controllers/faq_controller.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:template_c/feat/profile/state/profile_state.dart';
import 'package:template_c/feat/profile/presentation/settings_bottom_sheet.dart';
import 'package:template_c/feat/interest/presentation/interest_selection_screen.dart';

void showProfileBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => const ProfileBottomSheet(),
  );
}

// Brand colors not present in AppColors model
const _kAvatarBlue = Color(0xFFD0E5FB);

class ProfileBottomSheet extends BaseStatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  ConsumerState<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState
    extends BaseStatefulWidgetState<ProfileBottomSheet>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).getVersionName();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(profileControllerProvider.notifier).getProfile();
      ref.read(profileControllerProvider.notifier).loadNotificationStatus();
    }
  }

  _executeAction(LegalType legalType, String title) {
    final state = ref.read(legalControllerProvider);

    final legalData = state.legalResponseModel?.data?.firstWhere(
      (element) => element.key == legalType.name,
      orElse: () => LegalData(),
    );
    if (legalData?.action != null) {
      ref
          .read(templateCHandlerProvider)
          .executeAction(context, legalData!.action!, title: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    ref.watch(faqProvider);
    ref.watch(legalControllerProvider);
    final appColors = ref.watch(appThemeProvider).colors;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = appColors.getTextColor(isDark);
    final subTextColor = theme.colorScheme.onSurfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Theme.of(context).dividerColor;
    final primaryColor = appColors.primary;
    final errorColor = appColors.error;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          CommonBottomSheetHeader(
            showBackButton: false,
            title: 'profile'.tr,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              // padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(
                    context,
                    profile,
                    textColor,
                    subTextColor,
                    surfaceColor,
                    dividerColor,
                    primaryColor,
                    profile.isGuestUser,
                  ),
                  SizedBox(height: 18.h),
                  _buildInterestsAndLocationRow(
                    surfaceColor,
                    dividerColor,
                    primaryColor,
                    textColor,
                    context,
                    ref,
                  ),
                  SizedBox(height: 48.h),
                  _buildSettingsSections(
                    context,
                    profile,
                    controller,
                    ref,
                    textColor,
                    dividerColor,
                    primaryColor,
                    errorColor,
                    profile.version,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile Card ──────────────────────────────────────────────────────────

  Widget _buildProfileCard(
    BuildContext context,
    ProfileState profile,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color dividerColor,
    Color primaryColor,
    bool isGuest,
  ) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        // color: surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(
                profile.data?.avatarUrl,
                textColor,
                context,
                isGuest,
              ),
              SizedBox(width: 18.w),
              _buildUserInfo(
                profile.data?.firstName,
                profile.data?.lastName,
                profile.data?.email,
                textColor,
                subTextColor,
                profile.isGuestUser,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildStatsRow(
            profile.data?.events,
            profile.data?.organizer,
            textColor,
            subTextColor,
            dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String? avatarUrl,
    Color textColor,
    BuildContext context,
    bool isGuest,
  ) {
    return GestureDetector(
      onTap: isGuest
          ? null
          : () {
              context.pushNamed(RouteConstant.editProfile.name);
            },
      child: Container(
        width: 76.w,
        height: 76.h,
        decoration: const BoxDecoration(
          color: _kAvatarBlue,
          shape: BoxShape.circle,
        ),
        child: avatarUrl != null
            ? ClipOval(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  width: 76.w,
                  height: 76.h,
                  errorBuilder: (_, _, _) =>
                      _addPhotoPlaceholder(textColor, isGuest),
                ),
              )
            : _addPhotoPlaceholder(textColor, isGuest),
      ),
    );
  }

  Widget _addPhotoPlaceholder(Color textColor, bool isGuest) {
    if (isGuest) {
      return Center(
        child: CommonText(
          titleText: 'GU',
          textStyle: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/svg/camera_icon.svg',
          width: 20.sp,
          height: 20.sp,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        ),
        SizedBox(height: 2.h),
        CommonText(
          titleText: 'add'.tr,
          textStyle: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(
    String? firstName,
    String? lastName,
    String? email,
    Color textColor,
    Color subTextColor,
    bool isGuest,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: (firstName != '' && lastName != '')
                ? "$firstName $lastName"
                : "- -",
            textStyle: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          if (!isGuest) ...[
            SizedBox(height: 2.h),
            CommonText(
              titleText: email ?? "-",
              textStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: subTextColor,
                letterSpacing: 0.24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    int? events,
    int? organizer,
    Color textColor,
    Color subTextColor,
    Color dividerColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: dividerColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(color: dividerColor),
              ),
              child: Center(
                child: CommonText(
                  titleText: 'favorites'.tr,
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 24.w),
        _buildStatItem(events ?? 0, 'Events', textColor, subTextColor),
        SizedBox(width: 18.w),
        Container(width: 1, height: 32.h, color: dividerColor),
        SizedBox(width: 18.w),
        _buildStatItem(organizer ?? 0, 'organizer'.tr, textColor, subTextColor),
      ],
    );
  }

  Widget _buildStatItem(
    int count,
    String label,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          titleText: count.toString(),
          textStyle: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        CommonText(
          titleText: label,
          textStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: subTextColor,
            letterSpacing: 0.24,
          ),
        ),
      ],
    );
  }

  // // ─── Interests & Location ──────────────────────────────────────────────────

  Widget _buildInterestsAndLocationRow(
    Color surfaceColor,
    Color dividerColor,
    Color primaryColor,
    Color textColor,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInterestsCard(
            surfaceColor,
            dividerColor,
            textColor,
            context,
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: _buildLocationCard(
            surfaceColor,
            dividerColor,
            primaryColor,
            textColor,
            context,
            ref,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsCard(
    Color surfaceColor,
    Color dividerColor,
    Color textColor,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        showInterestBottomSheet(
          context,
          interestSelectionParams: InterestSelectionParams(
            isSkip: false,
            onConfirm: (context) {
              if (context.mounted) {
                // Navigator.of(context).pop();
                ref.invalidate(homeControllerProvider);
                ref.read(homeControllerProvider.notifier).refreshAll();
              }
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: dividerColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 54,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 100.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 35.w,
                    top: 0,
                    child: Transform.rotate(
                      angle: 0.032,
                      child: _buildInterestPin(
                        Icons.theater_comedy_outlined,
                        dividerColor,
                        context,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 25.w,
                    top: 28.h,
                    child: Transform.rotate(
                      angle: -0.101,
                      child: _buildInterestPin(
                        Icons.bar_chart_outlined,
                        dividerColor,
                        context,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20.w,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: 0.133,
                      child: _buildInterestPin(
                        Icons.chat_bubble_outline,
                        dividerColor,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildPillButton('interests'.tr, dividerColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestPin(
    IconData icon,
    Color dividerColor,
    BuildContext context,
  ) {
    return Container(
      width: 42.w,
      height: 52.h,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 5.h,
            child: Icon(Icons.location_pin, size: 32.sp, color: dividerColor),
          ),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: dividerColor,
            ),
            child: Container(
              width: 33.w,
              height: 33.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(icon, size: 18.sp, color: const Color(0xFF151B23)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    Color surfaceColor,
    Color dividerColor,
    Color primaryColor,
    Color textColor,
    BuildContext context,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteConstant.locationOnboarding.name,
          extra: LocationOnboardingParams(
            isSkip: false,
            onConfirm: (context) {
              ref.read(homeControllerProvider.notifier).refreshAll();
              if (context.mounted) {
                // Close screen + profile sheet and then ensure bottom nav is shown.
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                context.goNamed(RouteConstant.bottomNav.name);
              }
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: dividerColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 54,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: dividerColor, width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    offset: Offset(0, 1.73),
                    blurRadius: 10.4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(painter: _MapPlaceholderPainter()),
                    ),
                    Center(
                      child: Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          color: primaryColor.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.my_location,
                          size: 20.sp,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildPillButton('your_location'.tr, dividerColor, textColor),
          ],
        ),
      ),
    );
  }

  /// Pill-shaped label button used inside the Interests and Location cards.
  Widget _buildPillButton(String label, Color dividerColor, Color textColor) {
    return Container(
      height: 36.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: dividerColor),
      ),
      child: Center(
        child: CommonText(
          titleText: label,
          textStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // // ─── Settings list ─────────────────────────────────────────────────────────

  Widget _buildSettingsSections(
    BuildContext context,
    ProfileState profile,
    ProfileController controller,
    WidgetRef ref,
    Color textColor,
    Color dividerColor,
    Color primaryColor,
    Color errorColor,
    String version,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notifications toggle row
        if (isNotificationEnabled) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: CommonMenuRow(
              iconWidget: SvgPicture.asset(
                'assets/svg/notification_bell_icon.svg',
                width: 20.sp,
                height: 20.sp,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
              label: 'notifications'.tr,
              trailing: CommonSwitchToggle(
                value: profile.notificationsEnabled,
                onChanged: (_) async {
                  await openAppSettings();
                },
                activeColor: primaryColor,
              ),
            ),
          ),

          SizedBox(height: 36.h),
          Divider(color: dividerColor, height: 1, thickness: 1),
          SizedBox(height: 36.h),
        ],

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/settings_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'settings'.tr,
                onTap: () => showSettingsBottomSheet(context),
              ),
              SizedBox(height: 32.h),
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/faq_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'faq'.tr,
                onTap: () {
                  final faqData = ref.read(faqProvider);
                  if (faqData?.action != null) {
                    ref
                        .read(templateCHandlerProvider)
                        .executeAction(
                          context,
                          faqData!.action!,
                          title: 'faq'.tr,
                        );
                  }
                },
              ),
              SizedBox(height: 32.h),
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/privacy_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'privacy'.tr,
                onTap: () async {
                  _executeAction(LegalType.privacyPolicy, 'privacy_policy'.tr);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 36.h),
        Divider(color: dividerColor, height: 1, thickness: 1),
        SizedBox(height: 36.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/box_arrow_up.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'share_app'.tr,
                onTap: () {},
              ),
              SizedBox(height: 32.h),
              CommonMenuRow(
                iconWidget: SvgPicture.asset(
                  'assets/svg/legal_icon.svg',
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    textColor, // match your theme
                    BlendMode.srcIn,
                  ),
                ),
                label: 'legal'.tr,
                onTap: () {
                  context.pushNamed(RouteConstant.legal.name);
                },
              ),
              SizedBox(height: 32.h),
              // Logout — no icon, no chevron, red text
              if (profile.isGuestUser == false)
                GestureDetector(
                  onTap: controller.logout,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: double.infinity,
                    child: CommonText(
                      titleText: 'log_out'.tr,
                      textStyle: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
                      ),
                    ),
                  ),
                ),
              if (profile.isGuestUser == true)
                GestureDetector(
                  onTap: () {
                    context.goNamed(RouteConstant.onboarding.name);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: double.infinity,
                    child: CommonText(
                      titleText: 'auth_signin_title'.tr,
                      textStyle: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 36.h),
        Divider(color: dividerColor, height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 36, 36, 36),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CommonText(
              titleText: '${'version'.tr} ${version}',
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Map Placeholder Painter ───────────────────────────────────────────────

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8EFF4),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFD0DCE8)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFFC2D0DC)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, 0),
      Offset(size.width * 0.38, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter oldDelegate) => false;
}
