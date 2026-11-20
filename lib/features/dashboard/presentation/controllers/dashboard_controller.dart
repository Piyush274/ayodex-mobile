import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/features/dashboard/data/models/dashboard_model.dart';
import 'package:ayodex/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardState {
  final bool isLoading;
  final DashboardDataModel? data;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardDataModel? data,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardController(this._repository) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.getDashboardData();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final dashboardControllerProvider = StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return DashboardController(repo);
});
