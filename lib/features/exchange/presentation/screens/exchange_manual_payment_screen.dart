import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/dynamic_form_builder.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import 'package:ayodex/features/exchange/data/repositories/exchange_repository.dart';

class ExchangeManualPaymentScreen extends ConsumerStatefulWidget {
  final String exchangeId;

  const ExchangeManualPaymentScreen({super.key, required this.exchangeId});

  @override
  ConsumerState<ExchangeManualPaymentScreen> createState() => _ExchangeManualPaymentScreenState();
}

class _ExchangeManualPaymentScreenState extends ConsumerState<ExchangeManualPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trxRefController = TextEditingController();
  final Map<String, dynamic> _formData = {};
  UploadedFile? _proofFile;

  bool _isLoading = false;
  ManualExchangeInstructions? _instructions;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  @override
  void dispose() {
    _trxRefController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructions() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(exchangeRepositoryProvider);
      final inst = await repo.getManualInstructions(widget.exchangeId);
      setState(() {
        _instructions = inst;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(exchangeRepositoryProvider);
      final fields = Map<String, dynamic>.from(_formData);
      if (_trxRefController.text.trim().isNotEmpty) {
        fields['transaction_id'] = _trxRefController.text.trim();
      }

      await repo.submitManualProof(
        exchangeId: widget.exchangeId,
        fields: fields,
        proofFile: _proofFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment proof submitted successfully!')),
        );
        context.go('/exchange/details?id=${widget.exchangeId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Instructions'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading && _instructions == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instructions Card
                      CustomCard(
                        title: 'Deposit Instructions',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _instructions?.instructions ??
                                  'Please make payment to the designated account and provide the transaction reference and receipt below.',
                              style: AppTextTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p20),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.p12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p16),
                      ],

                      // Transaction ID input
                      AppTextField(
                        controller: _trxRefController,
                        label: 'Transaction ID / Reference Code',
                        hint: 'e.g. TRX984210',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Transaction reference is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Proof File Upload
                      FileUploadCard(
                        label: 'Payment Screenshot / Proof Document',
                        instruction: 'Attach screenshot showing sender, amount, and reference',
                        allowedExtensions: const ['jpg', 'png', 'pdf'],
                        isRequired: true,
                        onFileSelected: (f) => setState(() => _proofFile = f),
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Dynamic Fields from server if present
                      if (_instructions?.requiredData != null) ...[
                        DynamicFormBuilder(
                          schema: _instructions!.requiredData!,
                          onChanged: (data) => _formData.addAll(data),
                        ),
                        const SizedBox(height: AppDimensions.p16),
                      ],

                      // Submit Button
                      AppButton(
                        text: 'Submit Payment Proof',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: AppDimensions.p24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
