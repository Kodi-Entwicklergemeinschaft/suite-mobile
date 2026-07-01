import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localization_controller.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/widgets/app_scaffold.dart';
import 'package:template_a/feat/bottom_navigation/controller/bottom_navigation_controller.dart';
import 'package:template_a/feat/home/controller/home_controller.dart';
import 'package:template_a/feat/user/profile/controller/profile_controller.dart';
import 'package:template_a/router/route_constant.dart';
import 'package:theme/theme.dart';

class SelectLanguageScreen extends BaseStatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  String get screenName => RouteConstant.userSettingsLanguage.name;

  @override
  ConsumerState<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

const _languageNames = {
  'en': 'English',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
  'it': 'Italiano',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'tr': 'Türkçe',
};

class _SelectLanguageScreenState extends BaseStatefulWidgetState<SelectLanguageScreen> {
  String? selectedLanguageCode;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    selectedLanguageCode = ref.read(localizationControllerProvider).languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadCityLanguages();
      ref.read(profileControllerProvider.notifier).loadLanguagePreference();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final secondaryColor = ref.watch(appThemeProvider).colors.secondary;

    ref.listen(profileControllerProvider, (previous, next) {
      final lang = next.preferredLanguage;
      if (lang != null &&
          previous?.preferredLanguage != lang &&
          !_isChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => selectedLanguageCode = lang);
          final currentCode = ref.read(localizationControllerProvider).languageCode;
          if (currentCode != lang) {
            ref.read(localizationControllerProvider.notifier).changeLocale(Locale(lang));
          }
        });
      }
    });

    return AppScaffold(
      appBar: const CommonAppBar(showBackButton: true),
      body: Stack(
        children: [
          Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10.h,
          children: [
            CommonText(
              titleText: 'language'.tr.toUpperCase(),
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (profileState.isLoadingLanguages)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: secondaryColor),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: profileState.enabledLanguages.length,
                  itemBuilder: (context, index) {
                    final langCode = profileState.enabledLanguages[index];
                    return Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Semantics(
                        button: true,
                        label: _languageNames[langCode] ?? langCode.toUpperCase(),
                        selected: selectedLanguageCode == langCode,
                        child: InkWell(
                        onTap: () async {
                          if (selectedLanguageCode == langCode) return;
                          setState(() { selectedLanguageCode = langCode; _isChanging = true; });
                          ref.read(preferenceManagerProvider).saveString('locale', langCode);
                          await Future.wait([
                            ref.read(profileControllerProvider.notifier).updateLanguage(langCode),
                            ref.read(bottomNavigationProvider.notifier).refreshLabels(),
                          ]);
                          if (!mounted) return;
                          ref.read(localizationControllerProvider.notifier).changeLocale(Locale(langCode));
                          ref.read(homeControllerProvider.notifier).refresh();
                          setState(() => _isChanging = false);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              ExcludeSemantics(
                                child: Radio<String>(
                                  value: langCode,
                                  groupValue: selectedLanguageCode,
                                  fillColor: WidgetStateProperty.all(secondaryColor),
                                  onChanged: (value) async {
                                    if (value == null || selectedLanguageCode == value) return;
                                    setState(() { selectedLanguageCode = value; _isChanging = true; });
                                    ref.read(preferenceManagerProvider).saveString('locale', value);
                                    await Future.wait([
                                      ref.read(profileControllerProvider.notifier).updateLanguage(value),
                                      ref.read(bottomNavigationProvider.notifier).refreshLabels(),
                                    ]);
                                    if (!mounted) return;
                                    ref.read(localizationControllerProvider.notifier).changeLocale(Locale(value));
                                    ref.read(homeControllerProvider.notifier).refresh();
                                    setState(() => _isChanging = false);
                                  },
                                ),
                              ),
                              CommonText(
                                titleText: _languageNames[langCode] ?? langCode.toUpperCase(),
                                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).extension<AppTextColors>()!.inverse,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
          ),
          if (_isChanging)
            Center(
              child: CircularProgressIndicator(color: secondaryColor),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    selectedLanguageCode = null;
    super.dispose();
  }
}
