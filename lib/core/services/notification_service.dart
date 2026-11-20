import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/notifications/data/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  /// Registers the device push notification token upon user sign in
  Future<void> registerPushToken([String? token]) async {
    try {
      final activeToken = token ?? 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
      await _repository.registerDeviceToken(activeToken);
    } catch (_) {
      // Non-fatal, gracefully ignored in environments without Google Play Services
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationService(repo);
});
