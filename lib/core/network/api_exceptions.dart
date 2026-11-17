class ApiException implements Exception {
  final String message;
  final String remark;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.remark = 'error',
    this.statusCode,
  });

  @override
  String toString() => message;
}

class UnauthenticatedException extends ApiException {
  const UnauthenticatedException({
    super.message = 'Session expired. Please sign in again.',
    super.remark = 'unauthenticated',
    super.statusCode = 401,
  });
}

class KycRequiredException extends ApiException {
  const KycRequiredException({
    super.message = 'KYC verification is required to perform this transaction.',
    super.remark = 'kyc_verification',
    super.statusCode = 403,
  });
}

class KycUnderReviewException extends ApiException {
  const KycUnderReviewException({
    super.message = 'Your KYC documents are currently under review.',
    super.remark = 'under_review',
    super.statusCode = 403,
  });
}

class RateLimitException extends ApiException {
  final int? retryAfterSeconds;

  const RateLimitException({
    super.message = 'Too many requests. Please try again shortly.',
    super.remark = 'rate_limited',
    super.statusCode = 429,
    this.retryAfterSeconds,
  });
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection or server unreachable. Please check your network.',
    super.remark = 'network_error',
    super.statusCode,
  });
}

class ValidationException extends ApiException {
  final List<String> errors;

  ValidationException({
    required super.message,
    super.remark = 'validation_error',
    super.statusCode = 422,
    this.errors = const [],
  });
}

class WithdrawDisabledException extends ApiException {
  const WithdrawDisabledException({
    super.message = 'Withdrawals are currently disabled by the platform.',
    super.remark = 'withdraw_disabled',
    super.statusCode = 403,
  });
}
