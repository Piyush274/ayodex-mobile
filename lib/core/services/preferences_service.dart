import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _keyLanguage = 'ayodex_language_code';
  static const String _keyOnboardingSeen = 'ayodex_onboarding_seen';
  static const String _keyHideBalance = 'ayodex_hide_balance';
  static const String _keyCachedCountries = 'ayodex_cached_countries';

  String getLanguageCode() {
    return _prefs.getString(_keyLanguage) ?? 'fr'; // French is default per website
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_keyLanguage, code);
  }

  bool isOnboardingSeen() {
    return _prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  Future<void> setOnboardingSeen(bool seen) async {
    await _prefs.setBool(_keyOnboardingSeen, seen);
  }

  bool isBalanceHidden() {
    return _prefs.getBool(_keyHideBalance) ?? false;
  }

  Future<void> setBalanceHidden(bool hidden) async {
    await _prefs.setBool(_keyHideBalance, hidden);
  }

  String? getCachedCountries() {
    return _prefs.getString(_keyCachedCountries);
  }

  Future<void> setCachedCountries(String jsonString) async {
    await _prefs.setString(_keyCachedCountries, jsonString);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
