import 'package:locale/locale_initializer.dart';
import 'package:common_components/src/utils/datetimehelper/localization/date_time_en.dart';
import 'package:common_components/src/utils/datetimehelper/localization/date_time_de.dart';

/// Registers shared datetime translation keys with the locale system.
/// Call this once during app startup, before [runApp], alongside other
/// feature localization initializers.
void initializeDateTimeLocalizations() {
  LocaleInitializer.registerFeatureTranslations('en', dateTimeEn);
  LocaleInitializer.registerFeatureTranslations('de', dateTimeDe);
}
