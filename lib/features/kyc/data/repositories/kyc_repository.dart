import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';

class KycFormResult {
  final String remark;
  final DynamicFormModel? form;

  const KycFormResult({
    required this.remark,
    this.form,
  });

  bool get isAlreadyVerified => remark == 'already_verified';
  bool get isUnderReview => remark == 'under_review';
  bool get isPendingSubmission => form != null;
}

class KycRepository extends BaseRepository {
  KycRepository(super.apiClient);

  /// Fetch dynamic KYC schema or check status
  Future<KycFormResult> getKycForm() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.kycForm);
    });

    if (response is Map<String, dynamic>) {
      final remark = response['remark']?.toString() ?? 'kyc_form';
      final dynamic formData = response['form'] ?? response['data']?['form'] ?? response['formData'];
      return KycFormResult(
        remark: remark,
        form: formData != null ? DynamicFormModel.fromJson(formData) : null,
      );
    }
    return const KycFormResult(remark: 'kyc_form');
  }

  /// Submit dynamic KYC form fields and uploaded documents via multipart
  Future<void> submitKyc({
    required Map<String, dynamic> formFields,
    required Map<String, UploadedFile> files,
  }) async {
    final Map<String, dynamic> dataMap = Map.from(formFields);

    for (final entry in files.entries) {
      dataMap[entry.key] = MultipartFile.fromBytes(
        [0], // Simulated bytes for payload representation
        filename: entry.value.name,
      );
    }

    final formData = FormData.fromMap(dataMap);

    await handleApiCall(() async {
      return await apiClient.postMultipart<dynamic>(
        ApiEndpoints.kycSubmit,
        formData: formData,
      );
    });
  }
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KycRepository(apiClient);
});
