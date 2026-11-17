import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/country_model.dart';
import 'package:ayodex/core/models/general_setting_model.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/api_exceptions.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/core/services/secure_storage_service.dart';

class AuthRepository extends BaseRepository {
  final SecureStorageService secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required this.secureStorage,
  }) : super(apiClient);

  Future<GeneralSettingModel> getGeneralSetting() async {
    final response = await apiClient.get<GeneralSettingModel>(
      ApiEndpoints.generalSetting,
      fromJsonData: (data) {
        if (data is Map<String, dynamic> && data['general_setting'] != null) {
          return GeneralSettingModel.fromJson(data['general_setting'] as Map<String, dynamic>);
        }
        return const GeneralSettingModel();
      },
    );
    return response.data ?? const GeneralSettingModel();
  }

  Future<List<CountryModel>> getCountries() async {
    final response = await apiClient.get<List<CountryModel>>(
      ApiEndpoints.getCountries,
      fromJsonData: (data) {
        if (data is Map<String, dynamic> && data['countries'] is List) {
          return (data['countries'] as List)
              .map((c) => CountryModel.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        return <CountryModel>[];
      },
    );
    return response.data ?? <CountryModel>[];
  }

  Future<bool> checkToken(String token) async {
    try {
      final response = await apiClient.post<dynamic>(
        ApiEndpoints.checkToken,
        data: {'token': token},
      );
      return response.remark == 'token_exists';
    } catch (_) {
      return false;
    }
  }

  Future<UserModel> getUserInfo() async {
    final response = await apiClient.get<UserModel>(
      ApiEndpoints.userInfo,
      fromJsonData: (data) {
        if (data is Map<String, dynamic> && data['user'] != null) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
        throw const ApiException(message: 'Invalid user profile data');
      },
    );
    return response.data!;
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'username': username.trim(),
        'password': password,
      },
      fromJsonData: (data) => data as Map<String, dynamic>,
    );

    final data = response.data;
    if (data == null || data['access_token'] == null) {
      throw const ApiException(message: 'Login failed: missing access token');
    }

    final token = data['access_token'].toString();
    final tokenType = data['token_type']?.toString() ?? 'Bearer';
    await secureStorage.saveToken(token, tokenType: tokenType);

    if (data['user'] != null && data['user'] is Map<String, dynamic>) {
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await secureStorage.saveUserId(user.id.toString());
      return user;
    }

    return await getUserInfo();
  }

  Future<UserModel> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool agree,
    String? reference,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'agree': agree ? 1 : 0,
        if (reference != null && reference.isNotEmpty) 'reference': reference.trim(),
      },
      fromJsonData: (data) => data as Map<String, dynamic>,
    );

    final data = response.data;
    if (data == null || data['access_token'] == null) {
      throw const ApiException(message: 'Registration failed: missing access token');
    }

    final token = data['access_token'].toString();
    final tokenType = data['token_type']?.toString() ?? 'Bearer';
    await secureStorage.saveToken(token, tokenType: tokenType);

    if (data['user'] != null && data['user'] is Map<String, dynamic>) {
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await secureStorage.saveUserId(user.id.toString());
      return user;
    }

    return await getUserInfo();
  }

  Future<UserModel> submitUserData({
    required String countryCode,
    required String country,
    required String mobileCode,
    required String username,
    required String mobile,
    String? address,
    String? city,
    String? state,
    String? zip,
  }) async {
    final response = await apiClient.post<UserModel>(
      ApiEndpoints.userDataSubmit,
      data: {
        'country_code': countryCode,
        'country': country,
        'mobile_code': mobileCode,
        'username': username.trim().toLowerCase(),
        'mobile': mobile.trim(),
        if (address != null) 'address': address.trim(),
        if (city != null) 'city': city.trim(),
        if (state != null) 'state': state.trim(),
        if (zip != null) 'zip': zip.trim(),
      },
      fromJsonData: (data) {
        if (data is Map<String, dynamic> && data['user'] != null) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
        throw const ApiException(message: 'Failed to parse completed profile');
      },
    );
    return response.data!;
  }

  Future<void> logout() async {
    try {
      await apiClient.get(ApiEndpoints.logout);
    } catch (_) {
      // Ignored: always clear local storage regardless of network error
    } finally {
      await secureStorage.clearToken();
    }
  }
}
