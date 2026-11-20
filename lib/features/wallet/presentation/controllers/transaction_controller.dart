import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/wallet/data/models/transaction_model.dart';
import 'package:ayodex/features/wallet/data/repositories/transaction_repository.dart';

class TransactionState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<TransactionModel> transactions;
  final int currentPage;
  final bool hasNextPage;
  final String? searchQuery;
  final String? selectedType; // null, '+', '-'
  final String? selectedRemark;
  final List<String> availableRemarks;
  final String? errorMessage;

  const TransactionState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.transactions = const [],
    this.currentPage = 1,
    this.hasNextPage = true,
    this.searchQuery,
    this.selectedType,
    this.selectedRemark,
    this.availableRemarks = const [],
    this.errorMessage,
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<TransactionModel>? transactions,
    int? currentPage,
    bool? hasNextPage,
    String? searchQuery,
    String? selectedType,
    String? selectedRemark,
    List<String>? availableRemarks,
    String? errorMessage,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedRemark: selectedRemark ?? this.selectedRemark,
      availableRemarks: availableRemarks ?? this.availableRemarks,
      errorMessage: errorMessage,
    );
  }
}

class TransactionController extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;

  TransactionController(this._repository) : super(const TransactionState());

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null, currentPage: 1);
    try {
      final result = await _repository.getTransactions(
        page: 1,
        search: state.searchQuery,
        type: state.selectedType,
        remark: state.selectedRemark,
      );

      state = state.copyWith(
        isLoading: false,
        transactions: result.paginated.data,
        currentPage: 1,
        hasNextPage: result.paginated.hasMorePages,
        availableRemarks: result.remarks.isNotEmpty ? result.remarks : state.availableRemarks,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final result = await _repository.getTransactions(
        page: nextPage,
        search: state.searchQuery,
        type: state.selectedType,
        remark: state.selectedRemark,
      );

      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...result.paginated.data],
        currentPage: nextPage,
        hasNextPage: result.paginated.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String? query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    fetchInitial();
  }

  void setType(String? type) {
    if (state.selectedType == type) return;
    state = state.copyWith(selectedType: type);
    fetchInitial();
  }

  void setRemark(String? remark) {
    if (state.selectedRemark == remark) return;
    state = state.copyWith(selectedRemark: remark);
    fetchInitial();
  }
}

final transactionControllerProvider = StateNotifierProvider<TransactionController, TransactionState>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionController(repo);
});
