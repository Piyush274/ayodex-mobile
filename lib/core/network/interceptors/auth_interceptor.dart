import 'package:dio/dio.dart';
import '../../services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final void Function()? onSessionExpired;

  AuthInterceptor(this._storage, {this.onSessionExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';

    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final remark = data['remark']?.toString();
      if (remark == 'unauthenticated') {
        await _storage.clearToken();
        onSessionExpired?.call();
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clearToken();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
