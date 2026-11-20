import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ayodex/core/localization/app_localizations.dart';
import 'package:ayodex/core/localization/localization_repository.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/services/preferences_service.dart';
import 'package:ayodex/core/services/secure_storage_service.dart';

void main() {
  group('Localization Engine Tests', () {
    test('Translates English and French keys with parameter replacement', () {
      final enDict = {
        'welcome_back': 'Welcome Back, {name}!',
        'sign_in': 'Sign In',
        'exchange': 'Exchange',
      };

      final frDict = {
        'welcome_back': 'Bon retour, {name} !',
        'sign_in': 'Se connecter',
        'exchange': 'Échanger',
      };

      final enLocalization = AppLocalizations('en', enDict);
      final frLocalization = AppLocalizations('fr', frDict);

      expect(
        enLocalization.translate('welcome_back', args: {'name': 'Jane'}),
        'Welcome Back, Jane!',
      );

      expect(
        frLocalization.translate('welcome_back', args: {'name': 'Jane'}),
        'Bon retour, Jane !',
      );

      expect(frLocalization.translate('sign_in'), 'Se connecter');
      expect(enLocalization.translate('sign_in'), 'Sign In');
    });

    test('Falls back to key if translation missing', () {
      const localization = AppLocalizations('en', {});
      expect(localization.translate('missing_key'), 'missing_key');
    });

    test('LocaleNotifier changes locale and notifies listeners', () async {
      final storage = SecureStorageService();
      final apiClient = ApiClient(storageService: storage);
      final prefs = PreferencesService();
      final repo = LocalizationRepository(apiClient, prefs);
      final notifier = LocaleNotifier(repo);

      expect(notifier.state.languageCode, 'fr');
      await notifier.setLocale('en');
      expect(notifier.state.languageCode, 'en');
      await notifier.setLocale('fr');
      expect(notifier.state.languageCode, 'fr');
    });
  });
}
