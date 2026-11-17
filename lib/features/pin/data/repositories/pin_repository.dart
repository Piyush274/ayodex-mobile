import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import '../models/pin_status_model.dart';
import '../models/two_factor_model.dart';

class PinRepository extends BaseRepository {
  PinRepository(ApiClient apiClient) : super(apiClient);

  /// Get current PIN status (has_pin, is_locked, remaining minutes, requires_2fa)
  Future<PinStatusModel> getPinStatus() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.pinStatus);
    });

    if (response is Map<String, dynamic>) {
      return PinStatusModel.fromJson(response);
    }
    return const PinStatusModel();
  }

  /// Set new transaction PIN (requires account password and optional 2FA code)
  Future<void> setPin({
    required String password,
    required String pin,
    required String pinConfirmation,
    String? authenticatorCode,
  }) async {
    final data = <String, dynamic>{
      'password': password,
      'pin': pin,
      'pin_confirmation': pinConfirmation,
    };
    if (authenticatorCode != null && authenticatorCode.isNotEmpty) {
      data['authenticator_code'] = authenticatorCode;
    }

    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.pinSet,
        data: data,
      );
    });
  }

  /// Change existing transaction PIN
  Future<void> changePin({
    required String password,
    required String currentPin,
    required String pin,
    required String pinConfirmation,
    String? authenticatorCode,
  }) async {
    final data = <String, dynamic>{
      'password': password,
      'current_pin': currentPin,
      'pin': pin,
      'pin_confirmation': pinConfirmation,
    };
    if (authenticatorCode != null && authenticatorCode.isNotEmpty) {
      data['authenticator_code'] = authenticatorCode;
    }

    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.pinChange,
        data: data,
      );
    });
  }

  /// Get Google Authenticator 2FA setup details (secret, QR code URL)
  Future<TwoFactorModel> getTwoFactorInfo() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.twofactor);
    });

    if (response is Map<String, dynamic>) {
      return TwoFactorModel.fromJson(response);
    }
    return const TwoFactorModel(secret: '', qrCodeUrl: '');
  }

  /// Enable 2FA with secret key and authenticator OTP code
  Future<void> enableTwoFactor({
    required String key,
    required String code,
  }) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.twofactorEnable,
        data: {
          'key': key,
          'code': code,
        },
      );
    });
  }

  /// Disable 2FA with current authenticator OTP code
  Future<void> disableTwoFactor(String code) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.twofactorDisable,
        data: {'code': code},
      );
    });
  }
}

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PinRepository(apiClient);
});
