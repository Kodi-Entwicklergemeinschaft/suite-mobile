import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/feat/auth/controllers/auth_controller.dart';
import 'package:theme/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constant/common_enums.dart';
import '../../../core/constant/image.dart';
import '../../../router/route_constant.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../../core/widgets/user_type_card.dart';

void _showUserTypeInfoDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      final theme = Theme.of(dialogCtx);
      return Dialog(
        backgroundColor: theme.extension<AppContainerColors>()!.inverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 52.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonText(
                  titleText: message,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // TextButton(
                  //   onPressed: () => Navigator.of(dialogCtx).pop(),
                  //   child: CommonText(
                  //     titleText: 'cancel'.tr,
                  //     textStyle: TextStyle(
                  //       color: theme.colorScheme.secondary,
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 15.sp,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(width: 4.w),
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: CommonText(
                      titleText: 'ok'.tr,
                      textStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Second page of the onboarding flow - user type selection
class UserSelectionPage extends BaseStatefulWidget {
  const UserSelectionPage({super.key});

  @override
  ConsumerState<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends BaseStatefulWidgetState<UserSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (previous != next && next.state == StateEnum.success) {
        // Guest login success → Terms & Conditions (resident handled in AuthPage)
        context.goNamed(RouteConstant.termsConditions.name);
        ref.read(authControllerProvider.notifier).resetState();
      }
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTitle(),
          SizedBox(height: 6.h),
          _buildUserTypeCards(state),
          SizedBox(height: 40.h),
          _buildNextButton(state),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return CommonText(
      titleText: 'user_type_selection_title'.tr,
      textAlign: TextAlign.center,
      textScaler: TextScaler.noScaling,
      textStyle: TextStyle(
        color: AppColors.defaultColors.fontLight,
        fontSize: 28.w,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserTypeCards(dynamic state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10.w,
        children: [
          UserTypeCard(
            key: const Key("home"),
            text: 'user_type_home'.tr,
            value: UserTypeEnum.resident.toInt,
            imagePath: Images.houseIcon,
            semanticsLabel: 'user_type_home_card_label'.tr,
            selected: state.userType?.toInt,
            onTap: () => ref
                .read(authControllerProvider.notifier)
                .setUserType(UserTypeEnum.resident),
            onInfoTap: () => _showUserTypeInfoDialog(context, 'user_type_home_info'.tr),
          ),
          UserTypeCard(
            key: const Key("guest"),
            text: 'user_type_guest'.tr,
            value: UserTypeEnum.guest.toInt,
            imagePath: Images.guestIcon,
            semanticsLabel: 'user_type_guest_card_label'.tr,
            selected: state.userType?.toInt,
            onTap: () => ref
                .read(authControllerProvider.notifier)
                .setUserType(UserTypeEnum.guest),
            onInfoTap: () => _showUserTypeInfoDialog(context, 'user_type_guest_info'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(dynamic state) {
    final onboardingController = ref.read(onboardingControllerProvider.notifier);
    final isSelected = state.userType != null;
    return AppButton(
      'next'.tr,
      type: ButtonType.normal,
      size: ButtonSize.large,
      disabled: !isSelected,
      loading: state.state == StateEnum.loading,
      onPressed: () {
        if (state.userType == UserTypeEnum.resident) {
          ref.read(authControllerProvider.notifier).clearGuestSession().then((_) {
            onboardingController.onPageChanged(null);
          });
        } else {
          ref.read(authControllerProvider.notifier).guestLogin();
        }
      },
      bgColor: isSelected
          ? Theme.of(context).colorScheme.secondary
          : const Color(0xFF2C4158),
      fontSize: 20.sp,
    );
  }
}
