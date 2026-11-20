import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/language_model.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/core/services/preferences_service.dart';
import 'app_localizations.dart';

final localizationRepositoryProvider = Provider<LocalizationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return LocalizationRepository(apiClient, prefs);
});

class LocalizationRepository extends BaseRepository {
  final PreferencesService _preferencesService;

  LocalizationRepository(ApiClient apiClient, this._preferencesService)
      : super(apiClient);

  String getSavedLanguageCode() {
    return _preferencesService.getLanguageCode();
  }

  Future<void> saveLanguageCode(String code) async {
    await _preferencesService.setLanguageCode(code);
  }

  Future<Map<String, dynamic>> loadLocalDictionary(String code) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/translations/$code.json');
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchRemoteTranslations([String? code]) async {
    try {
      final path = code != null && code.isNotEmpty
          ? '${ApiEndpoints.language}/$code'
          : ApiEndpoints.language;
      final response = await apiClient.get(path);
      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        final file = data['file'];
        if (file is Map<String, dynamic>) {
          return file;
        }
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<List<LanguageModel>> getSupportedLanguages() async {
    try {
      final response = await apiClient.get(ApiEndpoints.language);
      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        final languagesList = data['languages'] as List<dynamic>?;
        if (languagesList != null) {
          return languagesList
              .map((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [
        const LanguageModel(id: 1, name: 'Français', code: 'fr', isDefault: true),
        const LanguageModel(id: 2, name: 'English', code: 'en', isDefault: false),
      ];
    } catch (_) {
      return [
        const LanguageModel(id: 1, name: 'Français', code: 'fr', isDefault: true),
        const LanguageModel(id: 2, name: 'English', code: 'en', isDefault: false),
      ];
    }
  }
}

final currentLocaleProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final repo = ref.watch(localizationRepositoryProvider);
  return LocaleNotifier(repo);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocalizationRepository _repository;

  LocaleNotifier(this._repository)
      : super(Locale(_repository.getSavedLanguageCode()));

  Future<void> setLocale(String code) async {
    if (state.languageCode == code) return;
    await _repository.saveLanguageCode(code);
    state = Locale(code);
  }
}

final appLocalizationsProvider = FutureProvider<AppLocalizations>((ref) async {
  final locale = ref.watch(currentLocaleProvider);
  return await AppLocalizations.load(locale);
});
