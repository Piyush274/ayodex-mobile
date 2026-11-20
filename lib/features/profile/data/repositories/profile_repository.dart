import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';

class ProfileRepository extends BaseRepository {
  ProfileRepository(super.apiClient);

  Future<UserModel> updateProfile({
    required String firstname,
    required String lastname,
    String? address,
    String? city,
    String? state,
    String? zip,
  }) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.profileSetting,
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'address': address ?? '',
          'city': city ?? '',
          'state': state ?? '',
          'zip': zip ?? '',
        },
      );
    });

    if (response is Map<String, dynamic>) {
      final userData = response['user'] ?? response['data']?['user'] ?? response['data'] ?? response;
      return UserModel.fromJson(userData as Map<String, dynamic>);
    }
    throw Exception('Invalid profile update response format');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    });
  }

  Future<void> deleteAccount() async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(ApiEndpoints.deleteAccount);
    });
  }

  Future<Map<String, dynamic>> getAffiliateData({int page = 1}) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.affiliate,
        queryParameters: {'page': page},
      );
    });

    if (response is Map<String, dynamic>) {
      return response;
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getPolicies() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.policies);
    });

    if (response is Map<String, dynamic>) {
      final dynamic list = response['policies'] ?? response['data']?['policies'] ?? response['data'] ?? response;
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    } else if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> getPolicyContent(String slug) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.policy}/$slug');
    });

    if (response is Map<String, dynamic>) {
      return response['policy'] ?? response['data']?['policy'] ?? response;
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getFaqs() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.faq);
    });

    if (response is Map<String, dynamic>) {
      final dynamic list = response['faqs'] ?? response['data']?['faqs'] ?? response['data'] ?? response;
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    } else if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> submitContact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.contact,
        data: {
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );
    });
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client);
});
