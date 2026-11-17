import 'dart:io';
import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'api_exceptions.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';
import 'interceptors/remark_interceptor.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({
    Dio? dio,
    required SecureStorageService storageService,
    void Function()? onSessionExpired,
    void Function()? onKycRequired,
  }) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: EnvConfig.baseUrl,
            connectTimeout: EnvConfig.connectTimeout,
            receiveTimeout: EnvConfig.receiveTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

    _dio.interceptors.addAll([
      AuthInterceptor(storageService, onSessionExpired: onSessionExpired),
      IdempotencyInterceptor(),
      RemarkInterceptor(onKycRequired: onKycRequired),
    ]);
  }

  Dio get rawDio => _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonData,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse<T>(response, fromJsonData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonData,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseResponse<T>(response, fromJsonData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonData,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          headers: {
            ...?options?.headers,
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );
      return _parseResponse<T>(response, fromJsonData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonData,
  ) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(body, fromJsonData);
    }
    return ApiResponse<T>(
      remark: 'raw_response',
      status: 'success',
      message: const ApiMessage(),
      data: body as T?,
    );
  }

  ApiException _handleDioError(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }

    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }

    final response = error.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final remark = data['remark']?.toString() ?? 'error';
      final message = ApiMessage.fromJson(data['message']);
      final errorText = message.error.isNotEmpty ? message.error.join('\n') : 'Request failed';

      if (response.statusCode == 401 || remark == 'unauthenticated') {
        return UnauthenticatedException(message: errorText, statusCode: response.statusCode);
      }
      if (response.statusCode == 429 || remark == 'rate_limited') {
        return RateLimitException(message: errorText, statusCode: response.statusCode);
      }
      return ApiException(
        message: errorText,
        remark: remark,
        statusCode: response.statusCode,
      );
    }

    return ApiException(
      message: error.message ?? 'An unknown network error occurred',
      statusCode: error.response?.statusCode,
    );
  }
}
