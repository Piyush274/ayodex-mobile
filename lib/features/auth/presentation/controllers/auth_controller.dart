import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/models/country_model.dart';
import 'package:ayodex/core/models/general_setting_model.dart';
import 'package:ayodex/core/models/user_model.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/features/auth/data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  profileIncomplete,
  banned,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final GeneralSettingModel? generalSetting;
  final List<CountryModel> countries;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.generalSetting,
    this.countries = const [],
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isProfileIncomplete => status == AuthStatus.profileIncomplete;
  bool get isBanned => status == AuthStatus.banned;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    GeneralSettingModel? generalSetting,
    List<CountryModel>? countries,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      generalSetting: generalSetting ?? this.generalSetting,
      countries: countries ?? this.countries,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState());

  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final settings = await _repository.getGeneralSetting();
      final countries = await _repository.getCountries();

      final token = await _repository.secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        final isValid = await _repository.checkToken(token);
        if (isValid) {
          final user = await _repository.getUserInfo();
          if (!user.isActive) {
            state = state.copyWith(
              status: AuthStatus.banned,
              user: user,
              generalSetting: settings,
              countries: countries,
            );
            return;
          }
          if (!user.isProfileComplete) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              user: user,
              generalSetting: settings,
              countries: countries,
            );
            return;
          }
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            generalSetting: settings,
            countries: countries,
          );
          return;
        } else {
          await _repository.secureStorage.clearToken();
        }
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        generalSetting: settings,
        countries: countries,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(username: username, password: password);
      if (!user.isActive) {
        state = state.copyWith(status: AuthStatus.banned, user: user);
        return false;
      }
      if (!user.isProfileComplete) {
        state = state.copyWith(status: AuthStatus.profileIncomplete, user: user);
        return true;
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool agree,
    String? reference,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.register(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        agree: agree,
        reference: reference,
      );
      state = state.copyWith(status: AuthStatus.profileIncomplete, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> completeProfile({
    required String countryCode,
    required String country,
    required String mobileCode,
    required String username,
    required String mobile,
    String? address,
    String? city,
    String? stateName,
    String? zip,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.submitUserData(
        countryCode: countryCode,
        country: country,
        mobileCode: mobileCode,
        username: username,
        mobile: mobile,
        address: address,
        city: city,
        state: stateName,
        zip: zip,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.profileIncomplete,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
