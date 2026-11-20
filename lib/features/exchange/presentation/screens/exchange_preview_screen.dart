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
import '../controllers/exchange_controller.dart';

class ExchangePreviewScreen extends ConsumerStatefulWidget {
  final String exchangeId;

  const ExchangePreviewScreen({super.key, required this.exchangeId});

  @override
  ConsumerState<ExchangePreviewScreen> createState() => _ExchangePreviewScreenState();
}

class _ExchangePreviewScreenState extends ConsumerState<ExchangePreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _externalFormData = {};
  String _destinationType = 'wallet'; // 'wallet' or 'external'
  final _walletIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exchangeControllerProvider.notifier).loadPreview(widget.exchangeId);
    });
  }

  @override
  void dispose() {
    _walletIdController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_destinationType == 'external' && _formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) return;
    }

    final result = await ref.read(exchangeControllerProvider.notifier).confirmExchange(
      exchangeId: widget.exchangeId,
      destinationType: _destinationType,
      walletId: _walletIdController.text.trim().isEmpty ? null : _walletIdController.text.trim(),
      dynamicFields: _destinationType == 'external' ? _externalFormData : null,
    );

    if (mounted && result != null) {
      if (result.isAutomatic && result.redirectUrl != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Payment Gateway'),
            content: Text('Automated payment gateway initiated: ${result.redirectUrl}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/exchange/details?id=${widget.exchangeId}');
                },
                child: const Text('Complete & Track'),
              ),
            ],
          ),
        );
      } else {
        context.push('/exchange/manual?id=${widget.exchangeId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exchangeControllerProvider);
    final preview = state.previewResult;
    final exchange = preview?.exchange ?? state.currentExchange;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exchange Preview'),
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading && exchange == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : exchange == null
                ? const Center(child: Text('Unable to load exchange preview'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.p20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Order Summary Card
                        CustomCard(
                          title: 'Order #${exchange.exchangeId}',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryRow(label: 'You Send', value: '${exchange.sendingAmount}'),
                              _SummaryRow(label: 'Sending Fee', value: '${exchange.sendingCharge}'),
                              _SummaryRow(label: 'Total Paid', value: '${exchange.totalSendingAmount}', isBold: true),
                              const Divider(height: 20),
                              _SummaryRow(label: 'You Receive', value: '${exchange.receivingAmount}'),
                              _SummaryRow(label: 'Receiving Fee', value: '${exchange.receivingCharge}'),
                              _SummaryRow(
                                label: 'Net Received',
                                value: '${exchange.totalReceivedAmount}',
                                isBold: true,
                                valueColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p20),

                        // Destination Type Selection
                        const Text('Choose Destination', style: AppTextTheme.headingMedium),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          title: const Text('AYODEX Internal Wallet'),
                          subtitle: const Text('Credit balance directly into your AYODEX wallet'),
                          value: 'wallet',
                          groupValue: _destinationType,
                          activeColor: AppColors.base,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _destinationType = val!),
                        ),
                        RadioListTile<String>(
                          title: const Text('External Account / Address'),
                          subtitle: const Text('Payout directly to your external bank, wallet or crypto address'),
                          value: 'external',
                          groupValue: _destinationType,
                          activeColor: AppColors.base,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _destinationType = val!),
                        ),
                        const SizedBox(height: AppDimensions.p16),

                        // Dynamic Form for External Destination
                        if (_destinationType == 'external') ...[
                          if (preview?.requiredData != null && preview!.requiredData!.fields.isNotEmpty) ...[
                            const Text('Recipient Details', style: AppTextTheme.headingMedium),
                            const SizedBox(height: 12),
                            DynamicFormBuilder(
                              formKey: _formKey,
                              schema: preview.requiredData!,
                              onChanged: (data) => _externalFormData.addAll(data),
                            ),
                          ] else ...[
                            AppTextField(
                              controller: _walletIdController,
                              label: 'External Wallet Address / Account',
                              hint: 'Enter your destination address',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Destination account is required';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: AppDimensions.p20),
                        ],

                        // Confirm Button
                        AppButton(
                          text: 'Confirm Exchange',
                          isLoading: state.isLoading,
                          onPressed: _handleConfirm,
                        ),
                        const SizedBox(height: AppDimensions.p24),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
          Text(
            value,
            style: AppTextTheme.bodyLarge.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}
