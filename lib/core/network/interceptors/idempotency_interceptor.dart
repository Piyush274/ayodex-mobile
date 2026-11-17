import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../constants/api_endpoints.dart';

class IdempotencyInterceptor extends Interceptor {
  final Uuid _uuid;

  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const List<String> _idempotentEndpoints = [
    ApiEndpoints.transferConfirm,
    ApiEndpoints.withdrawSave,
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST') {
      final isIdempotentEndpoint = _idempotentEndpoints.any((endpoint) => options.path.contains(endpoint));

      if (isIdempotentEndpoint) {
        if (!options.headers.containsKey('Idempotency-Key') || options.headers['Idempotency-Key'] == null) {
          final existingKey = options.extra['idempotency_key'] as String?;
          final key = existingKey ?? _uuid.v4();
          options.headers['Idempotency-Key'] = key;
          options.extra['idempotency_key'] = key;
        }
      }
    }

    handler.next(options);
  }
}
