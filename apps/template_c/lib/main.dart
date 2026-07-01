import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/locale_initializer.dart';
import 'package:locale/localization_controller.dart';
import 'package:locale/localizations.dart';
import 'package:locale/localizations_delegate.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/providers/app_providers.dart';
import 'package:template_c/feat/connectivity/constant/connectivity_constant.dart';
import 'package:template_c/feat/connectivity/controller/connectivity_controller.dart';
import 'package:template_c/loacalize_value/de.dart';
import 'package:template_c/loacalize_value/en.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:preference_manager/hive_service.dart';
import 'package:template_c/offline/offline_router/offline_router.dart';
import 'package:template_c/offline/theme_offline/controller/theme_offline_controller.dart';
import 'package:template_c/package_initializer.dart';
import 'package:template_c/router/router_provider.dart';
import 'package:template_c/theme_config/presentation/theme_data.dart';
import 'package:theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/app_update/app_update_gate.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // LOAD ENV
  await dotenv.load(fileName: './assets/env/.env');
  debugPrint('------  ENV FILE LOADED SUCESSFULLY -------');

  await initPreferences();

  // INIT HIVE
  await HiveService.init();
  HiveService.instance.registerAdapter(ListingModelAdapter());
  debugPrint('------  HIVE INITIALIZED SUCCESSFULLY -------');

  // Initialize translations from template project
  LocaleInitializer.initializeAppTranslations({'en': en, 'de': de});
  initializeDateTimeLocalizations();
  initializeAppUpdateLocalizations();

  debugPrint('------  LOCALE INTIALIZE SUCESSFULLY -------');

  runApp(ProviderScope(overrides: appProviderOverrides, child: TemplateCApp()));
}

class TemplateCApp extends BaseStatefulWidget {
  const TemplateCApp({super.key});

  @override
  ConsumerState<TemplateCApp> createState() => _TemplateCAppState();
}

class _TemplateCAppState extends BaseStatefulWidgetState<TemplateCApp> {
  @override
  void initState() {
    super.initState();
    initPackages(context);
    _loadCachedTheme();
  }

  Future<void> _loadCachedTheme() async {
    final cachedTheme =
        await ref.read(themeOfflineControllerProvider.notifier).getCachedTheme();
    if (cachedTheme != null && mounted) {
      ref.read(appThemeNotifierProvider.notifier).setAppTheme(cachedTheme);
    }
  }

  @override
  Widget build(BuildContext context) {

   final connectivity = ref.watch(connnectivityControllerProvider);

    if (connectivity.connectivityConstant == ConnectivityConstant.loading) {
      return const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      );
    }

    final status = connectivity.connectivityConstant;
    final appKey = ValueKey(status);

    if (connectivity.connectivityConstant ==
        ConnectivityConstant.isDisconnected) {
      final router = ref.watch(connectivityRouterProvider);
      final themeState = ref.watch(themeServiceProvider);
      final appTheme = ref.watch(appThemeProvider);
      final lightTheme = buildThemeData(appTheme.colors, Brightness.light, appTheme.font);
      final darkTheme = buildThemeData(appTheme.colors, Brightness.dark, appTheme.font);
      return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          key: appKey,
          themeMode: themeState.mode,
          theme: lightTheme,
             scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          darkTheme: darkTheme,
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


    final router = ref.read(routerProvider);
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

    return ScreenUtilInit(
      designSize: const Size(393, 852),
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
          return AppUpdateGate(
            child: SafeArea(
              top: false,
              bottom: Platform.isIOS ? false : true,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
