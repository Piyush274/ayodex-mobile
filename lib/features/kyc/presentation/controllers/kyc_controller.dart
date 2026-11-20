import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/kyc_repository.dart';

enum KycReviewStatus {
  unverified,
  underReview,
  verified,
}

class KycState {
  final bool isLoading;
  final KycReviewStatus status;
  final DynamicFormModel? schema;
  final String? errorMessage;
  final String? successMessage;

  const KycState({
    this.isLoading = false,
    this.status = KycReviewStatus.unverified,
    this.schema,
    this.errorMessage,
    this.successMessage,
  });

  KycState copyWith({
    bool? isLoading,
    KycReviewStatus? status,
    DynamicFormModel? schema,
    String? errorMessage,
    String? successMessage,
  }) {
    return KycState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      schema: schema ?? this.schema,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class KycController extends StateNotifier<KycState> {
  final KycRepository _repository;
  final Ref _ref;

  KycController(this._repository, this._ref) : super(const KycState());

  Future<void> fetchKycForm() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = _ref.read(authControllerProvider).user;
      if (user != null) {
        if (user.isKycVerified) {
          state = state.copyWith(isLoading: false, status: KycReviewStatus.verified);
          return;
        } else if (user.isKycPending) {
          state = state.copyWith(isLoading: false, status: KycReviewStatus.underReview);
          return;
        }
      }

      final result = await _repository.getKycForm();
      if (result.isAlreadyVerified) {
        state = state.copyWith(isLoading: false, status: KycReviewStatus.verified);
      } else if (result.isUnderReview) {
        state = state.copyWith(isLoading: false, status: KycReviewStatus.underReview);
      } else {
        state = state.copyWith(
          isLoading: false,
          status: KycReviewStatus.unverified,
          schema: result.form,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> submitKyc({
    required Map<String, dynamic> formFields,
    required Map<String, UploadedFile> files,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _repository.submitKyc(formFields: formFields, files: files);
      state = state.copyWith(
        isLoading: false,
        status: KycReviewStatus.underReview,
        successMessage: 'KYC documents submitted successfully and are under review',
      );
      // Refresh user profile info
      await _ref.read(authControllerProvider.notifier).initialize();
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

final kycControllerProvider = StateNotifierProvider<KycController, KycState>((ref) {
  final repo = ref.watch(kycRepositoryProvider);
  return KycController(repo, ref);
});
