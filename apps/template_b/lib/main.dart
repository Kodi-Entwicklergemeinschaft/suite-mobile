import 'package:common_components/common_components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/locale.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_b/feat/connectivity/constant/connectivity_constant.dart';
import 'package:template_b/feat/connectivity/controller/connectivity_controller.dart';
import 'package:template_b/localize_values/de.dart';
import 'package:template_b/localize_values/en.dart';
import 'package:template_b/routes/no_internet_route.dart';
import 'package:template_b/routes/router_provider.dart';
import 'package:template_b/theme_config/presentation/theme_data.dart';
import 'package:theme/theme.dart';
import 'core/providers/app_providers.dart';
import 'package:template_b/package_initializer.dart';
import 'package:template_b/notifications/notification_setup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:template_b/app_update/app_update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  registerNotificationBackgroundHandler();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // LOAD ENV — optional, app runs from local config assets when .env is absent
  try {
    await dotenv.load(fileName: './assets/env/.env');
    debugPrint('------  ENV FILE LOADED SUCESSFULLY -------');
  } catch (_) {
    debugPrint(
      '------  ENV FILE NOT FOUND, RUNNING IN OFFLINE/CONFIG MODE -------',
    );
  }

  await initPreferences();

  // Initialize translations from template project
  LocaleInitializer.initializeAppTranslations({'en': en, 'de': de});
  initializeAppUpdateLocalizations();

  debugPrint('------  LOCALE INTIALIZE SUCESSFULLY -------');
  runApp(ProviderScope(overrides: appProviderOverrides, child: TemplateBApp()));
}

class TemplateBApp extends BaseStatefulWidget {
  const TemplateBApp({super.key});

  @override
  ConsumerState<TemplateBApp> createState() => _TemplateBAppState();
}

class _TemplateBAppState extends BaseStatefulWidgetState<TemplateBApp> {
  @override
  void initState() {
    super.initState();
    initPackages(context);
    initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connnectivityControllerProvider);

    if (connectivity.connectivityConstant == ConnectivityConstant.loading) {
      return const MaterialApp(home: Scaffold(body: SizedBox.shrink()));
    }

    final status = connectivity.connectivityConstant;
    final appKey = ValueKey(status);

    if (connectivity.connectivityConstant ==
        ConnectivityConstant.isDisconnected) {
      final router = ref.watch(connectivityRouterProvider);
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          key: appKey,
          routerConfig: router,
          localizationsDelegates: AppLocalizationsDelegate.delegate,
          supportedLocales: AppLocalizationsDelegate.supportedLocales,
          locale: ref.watch(localizationControllerProvider),
          builder: (context, child) {
            initAppLocalizations(context);
            return child ?? const SizedBox.shrink();
          },
        ),
      );
    }

    final themeState = ref.watch(themeServiceProvider);
    final router = ref.watch(goRouterProvider);
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          key: appKey,
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
        );
      },
    );
  }
}
