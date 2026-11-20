import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import '../controllers/exchange_controller.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/exchange_calculation_box.dart';

class ExchangeCreateScreen extends ConsumerStatefulWidget {
  const ExchangeCreateScreen({super.key});

  @override
  ConsumerState<ExchangeCreateScreen> createState() => _ExchangeCreateScreenState();
}

class _ExchangeCreateScreenState extends ConsumerState<ExchangeCreateScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exchangeControllerProvider.notifier).loadCurrencies();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _openCurrencyPicker({required bool isSend}) {
    final state = ref.read(exchangeControllerProvider);
    final currencies = isSend
        ? state.currencies.where((c) => c.availableForSell).toList()
        : state.currencies.where((c) => c.availableForBuy).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CurrencySelectorSheet(
        title: isSend ? 'Select Sending Currency' : 'Select Receiving Currency',
        currencies: currencies,
        selectedCurrency: isSend ? state.selectedSendCurrency : state.selectedReceiveCurrency,
        onSelect: (selected) {
          if (isSend) {
            ref.read(exchangeControllerProvider.notifier).setSendCurrency(selected);
          } else {
            ref.read(exchangeControllerProvider.notifier).setReceiveCurrency(selected);
          }
        },
      ),
    );
  }

  Future<void> _handleProceed() async {
    final exchange = await ref.read(exchangeControllerProvider.notifier).createExchange();
    if (mounted && exchange != null) {
      context.push('/exchange/preview?id=${exchange.exchangeId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exchangeControllerProvider);
    final send = state.selectedSendCurrency;
    final receive = state.selectedReceiveCurrency;
    final amount = state.sendingAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Exchange'),
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading && state.currencies.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.base))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error Banner
                    if (state.errorMessage != null) ...[
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
                                state.errorMessage!,
                                style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),
                    ],

                    // Send Currency Selector
                    Text(
                      'You Send',
                      style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openCurrencyPicker(isSend: true),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.base.withOpacity(0.12),
                                  child: Text(
                                    send?.curSym.isNotEmpty == true ? send!.curSym[0] : '\$',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.base),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  send != null ? '${send.name} (${send.curSym})' : 'Select Currency',
                                  style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Amount Input
                    AppTextField(
                      controller: _amountController,
                      label: 'Sending Amount',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        width: 50,
                        child: Text(
                          send?.curSym ?? '\$',
                          style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = Decimal.tryParse(val.trim()) ?? Decimal.zero;
                        ref.read(exchangeControllerProvider.notifier).setSendingAmount(parsed);
                      },
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Swap Direction Indicator
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.base.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: AppColors.base, size: 24),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Receive Currency Selector
                    Text(
                      'You Receive',
                      style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openCurrencyPicker(isSend: false),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.success.withOpacity(0.12),
                                  child: Text(
                                    receive?.curSym.isNotEmpty == true ? receive!.curSym[0] : '\$',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  receive != null ? '${receive.name} (${receive.curSym})' : 'Select Currency',
                                  style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p24),

                    // Calculation Summary Box
                    if (send != null && receive != null) ...[
                      ExchangeCalculationBox(
                        sendingAmount: amount,
                        sendCurrency: send,
                        receiveCurrency: receive,
                      ),
                      const SizedBox(height: AppDimensions.p24),
                    ],

                    // Proceed Button
                    AppButton(
                      text: 'Proceed to Preview',
                      isLoading: state.isLoading,
                      onPressed: (send != null && receive != null && amount > Decimal.zero) ? _handleProceed : null,
                    ),
                    const SizedBox(height: AppDimensions.p24),
                  ],
                ),
              ),
      ),
    );
  }
}
