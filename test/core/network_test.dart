import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:ayodex/core/network/api_response.dart';
import 'package:ayodex/core/network/api_exceptions.dart';
import 'package:ayodex/core/network/interceptors/auth_interceptor.dart';
import 'package:ayodex/core/network/interceptors/idempotency_interceptor.dart';
import 'package:ayodex/core/services/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  String? storedToken;

  FakeSecureStorageService({this.storedToken});

  @override
  Future<String?> getToken() async => storedToken;

  @override
  Future<void> clearToken() async => storedToken = null;

  @override
  Future<String?> getTokenType() async => 'Bearer';

  @override
  Future<String?> getUserId() async => null;

  @override
  Future<bool> hasToken() async => storedToken != null && storedToken!.isNotEmpty;

  @override
  Future<void> saveToken(String token, {String tokenType = 'Bearer'}) async => storedToken = token;

  @override
  Future<void> saveUserId(String id) async {}

  @override
  Future<void> clearAll() async => storedToken = null;
}

void main() {
  group('ApiResponse Envelope Parsing Tests', () {
    test('Correctly parses standard success response', () {
      final json = {
        'remark': 'general_setting',
        'status': 'success',
        'message': {
          'success': ['General setting data']
        },
        'data': {'site_name': 'AYODEX'}
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.isSuccess, isTrue);
      expect(response.remark, 'general_setting');
      expect(response.message.success.first, 'General setting data');
      expect(response.data?['site_name'], 'AYODEX');
    });

    test('Correctly parses error response with remark and message', () {
      final json = {
        'remark': 'kyc_verification',
        'status': 'error',
        'message': {
          'error': ['KYC verification is required to perform this transaction.']
        },
        'data': {}
      };

      final response = ApiResponse<dynamic>.fromJson(json, (d) => d);
      expect(response.isSuccess, isFalse);
      expect(response.remark, 'kyc_verification');
      expect(response.getErrorMessage(), contains('KYC verification is required'));
    });
  });

  group('Interceptors Tests', () {
    test('AuthInterceptor attaches Authorization header when token exists', () async {
      final fakeStorage = FakeSecureStorageService(storedToken: 'test_token_123');

      final interceptor = AuthInterceptor(fakeStorage);
      final options = RequestOptions(path: '/user-info');

      final handler = RequestInterceptorHandler();
      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_token_123');
      expect(options.headers['Accept'], 'application/json');
    });

    test('AuthInterceptor does not attach Authorization header when token is null', () async {
      final fakeStorage = FakeSecureStorageService(storedToken: null);

      final interceptor = AuthInterceptor(fakeStorage);
      final options = RequestOptions(path: '/general-setting');

      final handler = RequestInterceptorHandler();
      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(options.headers['Accept'], 'application/json');
    });

    test('IdempotencyInterceptor injects Idempotency-Key on /transfer/confirm', () async {
      final interceptor = IdempotencyInterceptor();
      final options = RequestOptions(
        path: '/transfer/confirm',
        method: 'POST',
      );

      final handler = RequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Idempotency-Key'), isTrue);
      final key = options.headers['Idempotency-Key'] as String;
      expect(key.length, 36); // UUID v4 format: 8-4-4-4-12
    });

    test('IdempotencyInterceptor preserves existing key on retry', () async {
      final interceptor = IdempotencyInterceptor();
      const existingKey = '80bd46ee-1234-4567-8901-abcdef012345';
      final options = RequestOptions(
        path: '/transfer/confirm',
        method: 'POST',
        extra: {'idempotency_key': existingKey},
      );

      final handler = RequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      expect(options.headers['Idempotency-Key'], existingKey);
    });
  });

  group('ApiExceptions Tests', () {
    test('KycRequiredException has correct remark and status code', () {
      const exception = KycRequiredException();
      expect(exception.remark, 'kyc_verification');
      expect(exception.statusCode, 403);
    });

    test('RateLimitException has 429 status code', () {
      const exception = RateLimitException();
      expect(exception.statusCode, 429);
      expect(exception.remark, 'rate_limited');
    });

    test('UnauthenticatedException has 401 status code', () {
      const exception = UnauthenticatedException();
      expect(exception.statusCode, 401);
      expect(exception.remark, 'unauthenticated');
    });
  });
}
