import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/locale.dart';
import 'package:common_components/common_components.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:template_b/core/feature_flags.dart';
import 'package:template_b/feat/profile/presentation/widgets/menu_item_widget.dart';
import 'package:template_b/feat/settings/controller/settings_controller.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:template_b/core/providers/auth_state_provider.dart';

class SettingsScreen extends BaseStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseStatefulWidgetState<SettingsScreen>
    with WidgetsBindingObserver {
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(settingsControllerProvider.notifier)
          .refreshDevicePermissionStatus();
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
        ref
            .read(settingsControllerProvider.notifier)
            .recheckDeviceNotificationPermission();
      } else {
        ref
            .read(settingsControllerProvider.notifier)
            .refreshDevicePermissionStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsControllerProvider);
    final isLoggedIn = ref.watch(authStateProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'settings'.tr,
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isNotificationEnabled)
              MenuItemWidget(
                title: 'notification'.tr,
                onTap: () {},
                trailing: CommonSwitchToggle(
                  value: settingsState.isNotificationEnabled,
                  onChanged: (_) async {
                    _openedSettings = true;
                    await openAppSettings();
                  },
                ),
              ),
            MenuItemWidget(
              title: 'dark_mode'.tr,
              onTap: () {},
              trailing: CommonSwitchToggle(
                value: settingsState.isDarkMode,
                onChanged: (value) async {
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .toggleDarkMode(value);
                },
              ),
            ),
            if (isLoggedIn)
              MenuItemWidget(
                title: 'profile_settings'.tr,
                onTap: () =>
                    context.pushNamed(AppRouteConstants.profileSettings.name),
              ),
            MenuItemWidget(
              title: 'legal'.tr,
              onTap: () => context.pushNamed(AppRouteConstants.legal.name),
            ),
          ],
        ),
      ),
    );
  }
}
