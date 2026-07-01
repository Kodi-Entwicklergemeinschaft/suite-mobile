import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  static List<LocalizationsDelegate<dynamic>> delegate = [
    const AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static List<Locale> get supportedLocales {
    final registeredLocales = AppLocalizations.languages();
    return registeredLocales.map((code) => Locale(code)).toList();
  }

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.languages().contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
