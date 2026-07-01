import 'package:locale/locale_initializer.dart';
import 'package:common_components/src/widgets/localization/app_update_en.dart';
import 'package:common_components/src/widgets/localization/app_update_de.dart';

/// Registers app-update overlay translation keys with the locale system.
/// Call this once during app startup alongside other localization initializers.
void initializeAppUpdateLocalizations() {
  LocaleInitializer.registerFeatureTranslations('en', appUpdateEn);
  LocaleInitializer.registerFeatureTranslations('de', appUpdateDe);
}
