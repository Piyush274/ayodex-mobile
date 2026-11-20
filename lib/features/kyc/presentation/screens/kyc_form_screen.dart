import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/dynamic_form_builder.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import '../controllers/kyc_controller.dart';

class KycFormScreen extends ConsumerStatefulWidget {
  const KycFormScreen({super.key});

  @override
  ConsumerState<KycFormScreen> createState() => _KycFormScreenState();
}

class _KycFormScreenState extends ConsumerState<KycFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, UploadedFile> _formFiles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kycControllerProvider.notifier).fetchKycForm();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(kycControllerProvider.notifier).submitKyc(
      formFields: _formData,
      files: _formFiles,
    );

    if (mounted && success) {
      context.go('/kyc/status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycControllerProvider);

    // If already verified or under review, redirect to status screen
    if (!kycState.isLoading &&
        (kycState.status == KycReviewStatus.underReview ||
            kycState.status == KycReviewStatus.verified)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/kyc/status');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        elevation: 0,
      ),
      body: SafeArea(
        child: kycState.isLoading && kycState.schema == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instructions Banner
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_user_outlined, color: AppColors.info, size: 28),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KYC Compliance Requirement',
                                  style: AppTextTheme.headingMedium.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Verify your identity to unlock currency exchanges, transfers, and withdrawals across Benin & Nigeria.',
                                  style: AppTextTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p24),

                    // Error Banner
                    if (kycState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                kycState.errorMessage!,
                                style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                    ],

                    // Dynamic Form
                    if (kycState.schema != null) ...[
                      DynamicFormBuilder(
                        formKey: _formKey,
                        schema: kycState.schema!,
                        onChanged: (data) => _formData.addAll(data),
                        onFilesChanged: (files) => _formFiles.addAll(files),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                      AppButton(
                        text: 'Submit KYC',
                        isLoading: kycState.isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          'No verification documents required at this time.',
                          style: AppTextTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.p24),
                  ],
                ),
              ),
      ),
    );
  }
}
