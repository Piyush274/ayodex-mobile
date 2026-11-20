import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/features/transfers/data/models/bank_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';
import 'package:ayodex/features/transfers/data/models/transfer_quote_model.dart';
import 'package:ayodex/features/transfers/data/repositories/transfer_repository.dart';

class TransferState {
  final bool isLoading;
  final bool isResolvingAccount;
  final List<BankModel> banks;
  final BankModel? selectedBank;
  final String destinationType; // 'bank' or 'opay_wallet'
  final String? resolvedAccountName;
  final TransferQuoteModel? quote;
  final TransferModel? lastTransfer;
  final List<TransferModel> history;
  final bool hasMoreHistory;
  final int historyPage;
  final String? errorMessage;
  final String? successMessage;

  const TransferState({
    this.isLoading = false,
    this.isResolvingAccount = false,
    this.banks = const [],
    this.selectedBank,
    this.destinationType = 'bank',
    this.resolvedAccountName,
    this.quote,
    this.lastTransfer,
    this.history = const [],
    this.hasMoreHistory = false,
    this.historyPage = 1,
    this.errorMessage,
    this.successMessage,
  });

  TransferState copyWith({
    bool? isLoading,
    bool? isResolvingAccount,
    List<BankModel>? banks,
    BankModel? selectedBank,
    String? destinationType,
    String? resolvedAccountName,
    bool clearResolvedName = false,
    TransferQuoteModel? quote,
    bool clearQuote = false,
    TransferModel? lastTransfer,
    List<TransferModel>? history,
    bool? hasMoreHistory,
    int? historyPage,
    String? errorMessage,
    String? successMessage,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      isResolvingAccount: isResolvingAccount ?? this.isResolvingAccount,
      banks: banks ?? this.banks,
      selectedBank: selectedBank ?? this.selectedBank,
      destinationType: destinationType ?? this.destinationType,
      resolvedAccountName: clearResolvedName ? null : (resolvedAccountName ?? this.resolvedAccountName),
      quote: clearQuote ? null : (quote ?? this.quote),
      lastTransfer: lastTransfer ?? this.lastTransfer,
      history: history ?? this.history,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      historyPage: historyPage ?? this.historyPage,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TransferController extends StateNotifier<TransferState> {
  final TransferRepository _repository;

  TransferController(this._repository) : super(const TransferState());

  Future<void> loadBanks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final banks = await _repository.getBanks();
      BankModel? preselectedBank;
      if (banks.isNotEmpty) {
        if (state.destinationType == 'opay_wallet') {
          preselectedBank = banks.firstWhere(
            (b) => b.isOpay,
            orElse: () => banks.first,
          );
        } else {
          preselectedBank = banks.first;
        }
      }

      state = state.copyWith(
        isLoading: false,
        banks: banks,
        selectedBank: preselectedBank,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectDestinationType(String type) {
    BankModel? targetBank;
    if (type == 'opay_wallet') {
      try {
        targetBank = state.banks.firstWhere((b) => b.isOpay);
      } catch (_) {
        targetBank = state.selectedBank ??
            (state.banks.isNotEmpty
                ? state.banks.first
                : const BankModel(id: 'opay', code: 'opay', name: 'OPay / PayCom'));
      }
    } else {
      try {
        targetBank = state.banks.firstWhere((b) => !b.isOpay);
      } catch (_) {
        targetBank = state.banks.isNotEmpty ? state.banks.first : null;
      }
    }

    state = state.copyWith(
      destinationType: type,
      selectedBank: targetBank,
      clearResolvedName: true,
      clearQuote: true,
    );
  }

  void selectBank(BankModel bank) {
    state = state.copyWith(
      selectedBank: bank,
      clearResolvedName: true,
      clearQuote: true,
    );
  }

  Future<void> resolveAccount(String accountNumber) async {
    if (accountNumber.trim().length < 9) {
      state = state.copyWith(clearResolvedName: true);
      return;
    }

    final bank = state.selectedBank;
    if (bank == null) {
      state = state.copyWith(errorMessage: 'Please select a destination bank first');
      return;
    }

    state = state.copyWith(isResolvingAccount: true, errorMessage: null);
    try {
      final accountName = await _repository.resolveAccount(
        bankCode: bank.code,
        accountNumber: accountNumber.trim(),
      );
      state = state.copyWith(
        isResolvingAccount: false,
        resolvedAccountName: accountName,
      );
    } catch (e) {
      state = state.copyWith(
        isResolvingAccount: false,
        clearResolvedName: true,
        errorMessage: 'Could not resolve account: ${e.toString()}',
      );
    }
  }

  Future<TransferQuoteModel?> createQuote({
    required String accountNumber,
    required Decimal amount,
  }) async {
    final bank = state.selectedBank;
    final accountName = state.resolvedAccountName;

    if (bank == null) {
      state = state.copyWith(errorMessage: 'Please select a destination bank');
      return null;
    }
    if (accountName == null || accountName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please verify the recipient account number');
      return null;
    }
    if (amount <= Decimal.zero) {
      state = state.copyWith(errorMessage: 'Please enter a valid transfer amount');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final quote = await _repository.createQuote(
        destinationType: state.destinationType,
        bankCode: bank.code,
        accountNumber: accountNumber.trim(),
        accountName: accountName,
        amount: amount,
      );
      state = state.copyWith(isLoading: false, quote: quote);
      return quote;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<TransferModel?> confirmTransfer({
    required String pin,
    String? twofactorCode,
    String? idempotencyKey,
  }) async {
    final quote = state.quote;
    if (quote == null) {
      state = state.copyWith(errorMessage: 'No active transfer quote. Please recalculate.');
      return null;
    }
    if (quote.isExpired) {
      state = state.copyWith(errorMessage: 'This quote has expired. Please recalculate.');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final transfer = await _repository.confirmTransfer(
        quoteId: quote.quoteId,
        pin: pin,
        twofactorCode: twofactorCode,
        idempotencyKey: idempotencyKey,
      );
      state = state.copyWith(
        isLoading: false,
        lastTransfer: transfer,
        clearQuote: true,
        clearResolvedName: true,
        successMessage: 'Transfer dispatched successfully!',
      );
      return transfer;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loadTransferHistory({bool refresh = false, String? status}) async {
    final page = refresh ? 1 : state.historyPage;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final paginated = await _repository.getTransferHistory(page: page, status: status);
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

  void clearQuote() {
    state = state.copyWith(clearQuote: true);
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final transferControllerProvider = StateNotifierProvider<TransferController, TransferState>((ref) {
  final repo = ref.watch(transferRepositoryProvider);
  return TransferController(repo);
});
