// ============================================================================
// BloodNorms | app_localizations.dart
// i18n in English (en), Telugu (te), Hindi (hi)
// Enforces string budget (<= 28 chars for UI, <= 80 chars for helpers)
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'localized_strings.dart';

export 'localized_strings.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('te'),
    Locale('hi'),
  ];

  static Map<String, Map<String, String>> get _localizedValues =>
      localizedValues;

  String t(String key, [Map<String, String>? params]) {
    final lang = locale.languageCode;
    var value = _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  String get need => t('home.need');
  String get donor => t('home.donor');
  String get banks => t('home.banks');
  String get whatsapp => t('home.whatsapp');

  bool get isIndianScript => locale.languageCode == 'te' || locale.languageCode == 'hi';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'te', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

