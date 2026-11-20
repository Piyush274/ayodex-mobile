import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final String localeCode;
  final Map<String, dynamic> translations;

  const AppLocalizations(this.localeCode, [this.translations = const {}]);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations('en');
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  String translate(String key, {Map<String, dynamic>? args}) {
    var text = translations[key]?.toString() ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value.toString());
      });
    }

    return text;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final langCode = locale.languageCode;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$langCode.json',
      );
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AppLocalizations(langCode, jsonMap);
    } catch (_) {
      // Fallback if asset is missing or bundle not available
      return AppLocalizations(langCode, const {});
    }
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale.languageCode, const {}),
    );
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, dynamic>? args}) {
    return AppLocalizations.of(this).translate(key, args: args);
  }
}
