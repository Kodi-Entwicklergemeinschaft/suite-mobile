import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/feature_flags.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:theme/theme.dart';

class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends ConsumerState<NotificationPrefsScreen>
    with WidgetsBindingObserver {
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadNotificationPrefs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      if (_openedSettings) {
        _openedSettings = false;
        ref.read(profileControllerProvider.notifier).recheckDeviceNotificationPermission();
      } else {
        ref.read(profileControllerProvider.notifier).refreshDevicePermissionStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final isSaving = state.status == StateEnum.loadingDialog;
    final isGuest = ref.read(preferenceManagerProvider).getBool(StorageKeys.authIsGuest);

    ref.listen(profileControllerProvider, (previous, next) {
      if (previous?.status != next.status) {
        if (next.status == StateEnum.errorSnackBar && next.message != null) {
          AppSnackBar.showError(context, next.message!.tr);
          controller.resetMessageState();
        } else if (next.status == StateEnum.success && next.message != null) {
          AppSnackBar.showSuccess(context, next.message!.tr);
          controller.resetMessageState();
        }
      }
    });

    final effectiveToggleValue = isNotificationEnabled && state.deviceNotificationGranted && state.notificationsEnabled;

    return AppScaffold(
      appBar: const CommonAppBar(showBackButton: true),
      body: state.isLoadingNotificationPrefs
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        titleText: 'notifications'.tr.toUpperCase(),
                        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 22.h),
                      _buildToggleRow(
                        context: context,
                        label: 'push_notification'.tr,
                        value: effectiveToggleValue,
                        onChanged: isSaving
                            ? null
                            : (_) async {
                                if (!isNotificationEnabled) {
                                  AppSnackBar.showError(context, 'notification_service_disabled'.tr);
                                  return;
                                }
                                if (!state.deviceNotificationGranted) {
                                  _openedSettings = true;
                                  await openAppSettings();
                                  return;
                                }
                                await controller.saveNotificationPrefs(
                                notificationsOverride: !state.notificationsEnabled,
                              );
                              },
                      ),
                      if (!isGuest) ...[
                        SizedBox(height: 8.h),
                        _buildSubscribeRow(
                          context: context,
                          label: 'newsletter'.tr,
                          onPressed: isSaving
                              ? null
                              : () async {
                                  await controller.saveNotificationPrefs(
                                    newsletterOverride: true,
                                    successMessage: 'subscribe_request_sent',
                                  );
                                },
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSaving)
                  AbsorbPointer(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CommonText(
              titleText: label,
              overflow: TextOverflow.ellipsis,
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).extension<AppTextColors>()?.inverse,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.secondary;
              }
              return Colors.grey.shade600;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeRow({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CommonText(
              titleText: label,
              overflow: TextOverflow.ellipsis,
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).extension<AppTextColors>()?.inverse,
                  ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                ),
              ),
            ),
            child: AppButton(
              'subscribe'.tr,
              bgColor: Theme.of(context).colorScheme.secondary,
              textColor: Colors.white,
              height: 36.h,
              borderRadius: 8.r,
              fontSize: 15.sp,
              disabled: onPressed == null,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
