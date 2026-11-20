import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';

class PasswordResetRepository extends BaseRepository {
  PasswordResetRepository(super.apiClient);

  /// Step 1: Send verification code to email or username
  Future<String> sendResetCode(String value) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.passwordEmail,
        data: {
          'value': value,
          'type': 'email',
        },
      );
    });

    if (response is Map<String, dynamic>) {
      return response['email']?.toString() ?? value;
    }
    return value;
  }

  /// Step 2: Verify the 6-digit code and get verification token
  Future<String> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.passwordVerifyCode,
        data: {
          'email': email,
          'code': code,
        },
      );
    });

    if (response is Map<String, dynamic>) {
      return response['token']?.toString() ?? code;
    }
    return code;
  }

  /// Step 3: Set new password with the verification token
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.passwordReset,
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    });
  }

  /// Email verification OTP submission
  Future<void> verifyEmail(String code) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.verifyEmail,
        data: {'code': code},
      );
    });
  }

  /// SMS verification OTP submission
  Future<void> verifyMobile(String code) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.verifyMobile,
        data: {'code': code},
      );
    });
  }

  /// Google 2FA challenge OTP submission
  Future<void> verifyG2fa(String code) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.verifyG2fa,
        data: {'code': code},
      );
    });
  }

  /// Resend verification code ('email' or 'sms')
  Future<void> resendVerify(String type) async {
    await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        '${ApiEndpoints.resendVerify}/$type',
      );
    });
  }
}

final passwordResetRepositoryProvider =
    Provider<PasswordResetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PasswordResetRepository(apiClient);
});
