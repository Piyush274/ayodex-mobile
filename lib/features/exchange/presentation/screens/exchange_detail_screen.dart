import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/exchange/data/repositories/exchange_repository.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';

class ExchangeDetailScreen extends ConsumerStatefulWidget {
  final String exchangeId;

  const ExchangeDetailScreen({super.key, required this.exchangeId});

  @override
  ConsumerState<ExchangeDetailScreen> createState() => _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState extends ConsumerState<ExchangeDetailScreen> {
  ExchangeModel? _exchange;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(exchangeRepositoryProvider);
      final ex = await repo.getExchangeDetails(widget.exchangeId);
      setState(() {
        _exchange = ex;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exchange;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exchange Receipt'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : ex == null
                ? Center(child: Text(_errorMessage ?? 'Exchange not found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.p20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Receipt Header Card
                        CustomCard(
                          title: 'Receipt #${ex.exchangeId}',
                          trailing: StatusBadge(
                            label: ex.status == 1 ? 'Approved' : ex.status == 2 ? 'Pending' : 'Processed',
                            color: ex.status == 1 ? AppColors.success : AppColors.warning,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ReceiptRow(label: 'Order ID', value: ex.exchangeId),
                              if (ex.createdAt != null)
                                _ReceiptRow(label: 'Created Date', value: DateFormat('dd MMM yyyy, HH:mm').format(ex.createdAt!)),
                              _ReceiptRow(label: 'Destination Type', value: ex.destinationType.toUpperCase()),
                              if (ex.walletId != null)
                                _ReceiptRow(label: 'Destination Wallet', value: ex.walletId!),
                              const Divider(height: 24),
                              _ReceiptRow(label: 'Sending Amount', value: '${ex.sendingAmount}'),
                              _ReceiptRow(label: 'Sending Charge', value: '${ex.sendingCharge}'),
                              _ReceiptRow(label: 'Total Sent', value: '${ex.totalSendingAmount}', isBold: true),
                              const Divider(height: 24),
                              _ReceiptRow(label: 'Receiving Amount', value: '${ex.receivingAmount}'),
                              _ReceiptRow(label: 'Receiving Charge', value: '${ex.receivingCharge}'),
                              _ReceiptRow(
                                label: 'Total Received',
                                value: '${ex.totalReceivedAmount}',
                                isBold: true,
                                valueColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p24),

                        // Download PDF Receipt Button
                        AppButton(
                          text: 'Download Receipt (PDF)',
                          icon: Icons.picture_as_pdf_outlined,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ex.pdfDownloadPath != null
                                      ? 'Downloading receipt from: ${ex.pdfDownloadPath}'
                                      : 'Receipt PDF generated successfully.',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.p24),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted)),
          Text(
            value,
            style: AppTextTheme.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}
