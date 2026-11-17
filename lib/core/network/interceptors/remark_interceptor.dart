import 'package:dio/dio.dart';
import '../api_exceptions.dart';
import '../api_response.dart';

class RemarkInterceptor extends Interceptor {
  final void Function()? onKycRequired;

  RemarkInterceptor({this.onKycRequired});

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (data is Map<String, dynamic> && data.containsKey('status')) {
      final status = data['status']?.toString();
      final remark = data['remark']?.toString() ?? '';
      final message = ApiMessage.fromJson(data['message']);

      if (status == 'error') {
        final errorMessage = message.error.isNotEmpty
            ? message.error.join('\n')
            : 'An unexpected error occurred.';

        switch (remark) {
          case 'unauthenticated':
            throw UnauthenticatedException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          case 'kyc_verification':
            onKycRequired?.call();
            throw KycRequiredException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          case 'under_review':
            throw KycUnderReviewException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          case 'rate_limited':
            throw RateLimitException(
              message: errorMessage,
              statusCode: response.statusCode ?? 429,
            );
          case 'validation_error':
            throw ValidationException(
              message: errorMessage,
              errors: message.error,
              statusCode: response.statusCode ?? 422,
            );
          case 'withdraw_disabled':
            throw WithdrawDisabledException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          default:
            throw ApiException(
              message: errorMessage,
              remark: remark,
              statusCode: response.statusCode,
            );
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    if (err.response?.statusCode == 429) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const RateLimitException(),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    handler.next(err);
  }
}
