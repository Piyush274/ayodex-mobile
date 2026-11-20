import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import '../models/dashboard_model.dart';

class DashboardRepository extends BaseRepository {
  DashboardRepository(ApiClient apiClient) : super(apiClient);

  Future<DashboardDataModel> getDashboardData() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.dashboard);
    });

    if (response is Map<String, dynamic>) {
      return DashboardDataModel.fromJson(response);
    }
    throw Exception('Invalid dashboard data response shape');
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient);
});
