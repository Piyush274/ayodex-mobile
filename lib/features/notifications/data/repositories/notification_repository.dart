import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import '../models/notification_model.dart';

class NotificationRepository extends BaseRepository {
  NotificationRepository(super.apiClient);

  Future<void> registerDeviceToken(String token) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.addDeviceToken,
        data: {'token': token},
      );
    });
  }

  Future<PaginatedResponse<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.pushNotifications,
        queryParameters: {'page': page},
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic raw = response['notifications'] ?? response['data']?['notifications'] ?? response['data'] ?? response;
      if (raw is Map<String, dynamic>) {
        return PaginatedResponse<NotificationModel>.fromJson(
          raw,
          (json) => NotificationModel.fromJson(json),
        );
      }
    }
    return const PaginatedResponse<NotificationModel>();
  }

  Future<void> markAsRead(int id) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>('${ApiEndpoints.pushNotificationsRead}/$id');
    });
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRepository(client);
});
