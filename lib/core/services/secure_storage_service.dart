import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static const String _keyToken = 'ayodex_access_token';
  static const String _keyTokenType = 'ayodex_token_type';
  static const String _keyUserId = 'ayodex_user_id';

  Future<void> saveToken(String token, {String tokenType = 'Bearer'}) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyTokenType, value: tokenType);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getTokenType() async {
    return await _storage.read(key: _keyTokenType) ?? 'Bearer';
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyTokenType);
  }

  Future<void> saveUserId(String id) async {
    await _storage.write(key: _keyUserId, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
