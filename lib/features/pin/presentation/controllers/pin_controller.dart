import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/pin/data/models/pin_status_model.dart';
import 'package:ayodex/features/pin/data/models/two_factor_model.dart';
import 'package:ayodex/features/pin/data/repositories/pin_repository.dart';

class PinState {
  final bool isLoading;
  final PinStatusModel? status;
  final TwoFactorModel? twoFactor;
  final String? errorMessage;
  final String? successMessage;

  const PinState({
    this.isLoading = false,
    this.status,
    this.twoFactor,
    this.errorMessage,
    this.successMessage,
  });

  PinState copyWith({
    bool? isLoading,
    PinStatusModel? status,
    TwoFactorModel? twoFactor,
    String? errorMessage,
    String? successMessage,
  }) {
    return PinState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      twoFactor: twoFactor ?? this.twoFactor,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class PinController extends StateNotifier<PinState> {
  final PinRepository _repository;

  PinController(this._repository) : super(const PinState());

  Future<void> fetchPinStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final status = await _repository.getPinStatus();
      state = state.copyWith(isLoading: false, status: status);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchTwoFactor() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tf = await _repository.getTwoFactorInfo();
      state = state.copyWith(isLoading: false, twoFactor: tf);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> setPin({
    required String password,
    required String pin,
    required String pinConfirmation,
    String? authenticatorCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.setPin(
        password: password,
        pin: pin,
        pinConfirmation: pinConfirmation,
        authenticatorCode: authenticatorCode,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Transaction PIN set successfully',
        status: PinStatusModel(
          hasPin: true,
          isLocked: false,
          lockoutRemainingMinutes: 0,
          requires2fa: state.status?.requires2fa ?? false,
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> changePin({
    required String password,
    required String currentPin,
    required String pin,
    required String pinConfirmation,
    String? authenticatorCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.changePin(
        password: password,
        currentPin: currentPin,
        pin: pin,
        pinConfirmation: pinConfirmation,
        authenticatorCode: authenticatorCode,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Transaction PIN updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> enableTwoFactor({
    required String key,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.enableTwoFactor(key: key, code: code);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Two-factor authentication enabled successfully',
      );
      await fetchTwoFactor();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> disableTwoFactor(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.disableTwoFactor(code);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Two-factor authentication disabled successfully',
      );
      await fetchTwoFactor();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessage() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final pinControllerProvider = StateNotifierProvider<PinController, PinState>((ref) {
  final repo = ref.watch(pinRepositoryProvider);
  return PinController(repo);
});
