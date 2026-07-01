import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/locale_initializer.dart';
import 'package:locale/localization_controller.dart';
import 'package:locale/localizations.dart';
import 'package:locale/localizations_delegate.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/nav_key.dart';
import 'package:template_a/core/providers/app_providers.dart';
import 'package:template_a/package_initializer.dart';
import 'package:template_a/loacalize_value/de.dart';
import 'package:template_a/loacalize_value/en.dart';
import 'package:template_a/router/router_provider.dart';
import 'package:template_a/theme_config/presentation/theme_data.dart';
import 'package:theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_a/app_update/app_update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await dotenv.load(fileName: './assets/env/.env');
    debugPrint('------  ENV FILE LOADED SUCESSFULLY -------');
  } catch (_) {
    debugPrint('------  ENV FILE NOT FOUND, RUNNING IN OFFLINE MODE -------');
  }

  await initPreferences();

  LocaleInitializer.initializeAppTranslations({'en': en, 'de': de});

  debugPrint('------  LOCALE INTIALIZE SUCESSFULLY -------');

  runApp(
    ProviderScope(overrides: appProviderOverrides, child: const TemplateAApp()),
  );
}

class TemplateAApp extends BaseStatefulWidget {
  const TemplateAApp({super.key});

  @override
  ConsumerState<TemplateAApp> createState() => _TemplateAAppState();
}

class _TemplateAAppState extends BaseStatefulWidgetState<TemplateAApp> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    initPackages(context);
    _startConnectivityListener();
  }

  void _startConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOffline = results.contains(ConnectivityResult.none);

    if (isOffline && !_dialogShowing) {
      _dialogShowing = true;
      final ctx = globalNavKey.currentContext;
      if (ctx == null) return;
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (dialogCtx) {
          final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
          final bgColor = isDark
              ? Theme.of(dialogCtx).colorScheme.surface
              : Theme.of(dialogCtx).colorScheme.primary;
          final textColor = isDark ? Colors.black : Colors.white;
          return AlertDialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'no_internet'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            content: Text(
              'check_connection'.tr,
              style: TextStyle(color: textColor),
            ),
          );
        },
      );
    } else if (!isOffline && _dialogShowing) {
      _dialogShowing = false;
      final ctx = globalNavKey.currentContext;
      if (ctx != null && Navigator.of(ctx).canPop()) {
        Navigator.of(ctx).pop();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeServiceProvider);
    final appTheme = ref.watch(appThemeProvider);

    final lightTheme = buildThemeData(
      appTheme.colors,
      Brightness.light,
      appTheme.font,
    );
    final darkTheme = buildThemeData(
      appTheme.colors,
      Brightness.dark,
      appTheme.font,
    );

    const double refH = 1075;
    const double refW = 496;

    return ScreenUtilInit(
      designSize: const Size(refW, refH),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        themeMode: themeState.mode,
        theme: lightTheme,
        darkTheme: darkTheme,
        routerConfig: router,
        localizationsDelegates: AppLocalizationsDelegate.delegate,
        supportedLocales: AppLocalizationsDelegate.supportedLocales,
        locale: ref.watch(localizationControllerProvider),
        builder: (context, child) {
          initAppLocalizations(context);
          return AppUpdateGate(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
