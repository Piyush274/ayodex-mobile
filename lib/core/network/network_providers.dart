import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import 'api_client.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionExpiredEventProvider = StateProvider<bool>((ref) => false);
final kycRequiredEventProvider = StateProvider<bool>((ref) => false);

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return ApiClient(
    storageService: storage,
    onSessionExpired: () {
      ref.read(sessionExpiredEventProvider.notifier).state = true;
    },
    onKycRequired: () {
      ref.read(kycRequiredEventProvider.notifier).state = true;
    },
  );
});
