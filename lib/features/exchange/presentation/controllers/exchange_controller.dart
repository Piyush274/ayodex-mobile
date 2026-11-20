import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';
import 'package:ayodex/features/exchange/data/repositories/exchange_repository.dart';

class ExchangeState {
  final bool isLoading;
  final List<CurrencyModel> currencies;
  final CurrencyModel? selectedSendCurrency;
  final CurrencyModel? selectedReceiveCurrency;
  final Decimal sendingAmount;
  final ExchangeModel? currentExchange;
  final ExchangePreviewResult? previewResult;
  final List<ExchangeModel> history;
  final String? errorMessage;
  final String? successMessage;

  ExchangeState({
    this.isLoading = false,
    this.currencies = const [],
    this.selectedSendCurrency,
    this.selectedReceiveCurrency,
    Decimal? sendingAmount,
    this.currentExchange,
    this.previewResult,
    this.history = const [],
    this.errorMessage,
    this.successMessage,
  }) : sendingAmount = sendingAmount ?? Decimal.zero;

  ExchangeState copyWith({
    bool? isLoading,
    List<CurrencyModel>? currencies,
    CurrencyModel? selectedSendCurrency,
    CurrencyModel? selectedReceiveCurrency,
    Decimal? sendingAmount,
    ExchangeModel? currentExchange,
    ExchangePreviewResult? previewResult,
    List<ExchangeModel>? history,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExchangeState(
      isLoading: isLoading ?? this.isLoading,
      currencies: currencies ?? this.currencies,
      selectedSendCurrency: selectedSendCurrency ?? this.selectedSendCurrency,
      selectedReceiveCurrency: selectedReceiveCurrency ?? this.selectedReceiveCurrency,
      sendingAmount: sendingAmount ?? this.sendingAmount,
      currentExchange: currentExchange ?? this.currentExchange,
      previewResult: previewResult ?? this.previewResult,
      history: history ?? this.history,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ExchangeController extends StateNotifier<ExchangeState> {
  final ExchangeRepository _repository;

  ExchangeController(this._repository) : super(ExchangeState());

  Future<void> loadCurrencies() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currencies = await _repository.getCurrencies();
      CurrencyModel? send = state.selectedSendCurrency;
      CurrencyModel? receive = state.selectedReceiveCurrency;

      if (currencies.isNotEmpty) {
        send ??= currencies.firstWhere((c) => c.availableForSell, orElse: () => currencies.first);
        receive ??= currencies.firstWhere((c) => c.availableForBuy && c.id != send?.id, orElse: () => currencies.last);
      }

      state = state.copyWith(
        isLoading: false,
        currencies: currencies,
        selectedSendCurrency: send,
        selectedReceiveCurrency: receive,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSendCurrency(CurrencyModel currency) {
    state = state.copyWith(selectedSendCurrency: currency);
  }

  void setReceiveCurrency(CurrencyModel currency) {
    state = state.copyWith(selectedReceiveCurrency: currency);
  }

  void setSendingAmount(Decimal amount) {
    state = state.copyWith(sendingAmount: amount);
  }

  Future<ExchangeModel?> createExchange() async {
    final send = state.selectedSendCurrency;
    final receive = state.selectedReceiveCurrency;
    if (send == null || receive == null || state.sendingAmount <= Decimal.zero) {
      state = state.copyWith(errorMessage: 'Please select valid currencies and enter an amount.');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final exchange = await _repository.createExchange(
        sendingAmount: state.sendingAmount,
        sendingCurrencyId: send.id,
        receivingCurrencyId: receive.id,
      );
      state = state.copyWith(isLoading: false, currentExchange: exchange);
      return exchange;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loadPreview(String exchangeId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final preview = await _repository.getPreview(exchangeId);
      state = state.copyWith(isLoading: false, previewResult: preview, currentExchange: preview.exchange);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<ExchangeConfirmResult?> confirmExchange({
    required String exchangeId,
    required String destinationType,
    String? walletId,
    Map<String, dynamic>? dynamicFields,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.confirmExchange(
        exchangeId: exchangeId,
        destinationType: destinationType,
        walletId: walletId,
        dynamicFields: dynamicFields,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loadHistory({String? scope, int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final paginated = await _repository.getExchangeHistory(scope: scope, page: page);
      state = state.copyWith(isLoading: false, history: paginated.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final exchangeControllerProvider = StateNotifierProvider<ExchangeController, ExchangeState>((ref) {
  final repo = ref.watch(exchangeRepositoryProvider);
  return ExchangeController(repo);
});
