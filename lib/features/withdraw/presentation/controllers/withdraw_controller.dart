import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';
import 'package:ayodex/features/withdraw/data/models/withdrawal_model.dart';
import 'package:ayodex/features/withdraw/data/repositories/withdraw_repository.dart';

class WithdrawState {
  final bool isLoading;
  final bool isWithdrawDisabled;
  final String? disabledMessage;
  final List<CurrencyModel> currencies;
  final CurrencyModel? selectedCurrency;
  final List<WithdrawalModel> history;
  final bool hasMoreHistory;
  final int historyPage;
  final String? errorMessage;
  final String? successMessage;

  const WithdrawState({
    this.isLoading = false,
    this.isWithdrawDisabled = false,
    this.disabledMessage,
    this.currencies = const [],
    this.selectedCurrency,
    this.history = const [],
    this.hasMoreHistory = false,
    this.historyPage = 1,
    this.errorMessage,
    this.successMessage,
  });

  WithdrawState copyWith({
    bool? isLoading,
    bool? isWithdrawDisabled,
    String? disabledMessage,
    List<CurrencyModel>? currencies,
    CurrencyModel? selectedCurrency,
    List<WithdrawalModel>? history,
    bool? hasMoreHistory,
    int? historyPage,
    String? errorMessage,
    String? successMessage,
  }) {
    return WithdrawState(
      isLoading: isLoading ?? this.isLoading,
      isWithdrawDisabled: isWithdrawDisabled ?? this.isWithdrawDisabled,
      disabledMessage: disabledMessage ?? this.disabledMessage,
      currencies: currencies ?? this.currencies,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      history: history ?? this.history,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      historyPage: historyPage ?? this.historyPage,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class WithdrawController extends StateNotifier<WithdrawState> {
  final WithdrawRepository _repository;

  WithdrawController(this._repository) : super(const WithdrawState());

  Future<void> loadWithdrawMethods() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.getWithdrawMethods();
      if (result.isWithdrawDisabled) {
        state = state.copyWith(
          isLoading: false,
          isWithdrawDisabled: true,
          disabledMessage: result.message ?? 'Withdrawals are currently paused on the platform.',
        );
      } else {
        CurrencyModel? selected = state.selectedCurrency;
        if (result.currencies.isNotEmpty) {
          selected ??= result.currencies.first;
        }

        state = state.copyWith(
          isLoading: false,
          isWithdrawDisabled: false,
          currencies: result.currencies,
          selectedCurrency: selected,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectCurrency(CurrencyModel currency) {
    state = state.copyWith(selectedCurrency: currency);
  }

  Future<WithdrawalModel?> submitWithdraw({
    required Decimal amount,
    required Map<String, dynamic> formFields,
    String? idempotencyKey,
  }) async {
    final currency = state.selectedCurrency;
    if (currency == null) {
      state = state.copyWith(errorMessage: 'Please select a withdrawal currency');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final withdrawal = await _repository.submitWithdraw(
        currencyId: currency.id,
        amount: amount,
        dynamicFields: formFields,
        idempotencyKey: idempotencyKey,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Withdrawal request submitted successfully!',
      );
      return withdrawal;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loadWithdrawHistory({bool refresh = false, String? search}) async {
    final page = refresh ? 1 : state.historyPage;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final paginated = await _repository.getWithdrawHistory(page: page, search: search);
      final updatedHistory = refresh ? paginated.data : [...state.history, ...paginated.data];

      state = state.copyWith(
        isLoading: false,
        history: updatedHistory,
        hasMoreHistory: paginated.hasMorePages,
        historyPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final withdrawControllerProvider = StateNotifierProvider<WithdrawController, WithdrawState>((ref) {
  final repo = ref.watch(withdrawRepositoryProvider);
  return WithdrawController(repo);
});
