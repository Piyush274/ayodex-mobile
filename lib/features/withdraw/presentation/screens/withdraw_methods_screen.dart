import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/dynamic_form_builder.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/withdraw/presentation/controllers/withdraw_controller.dart';
import 'package:ayodex/features/withdraw/presentation/widgets/withdraw_currency_card.dart';

class WithdrawMethodsScreen extends ConsumerStatefulWidget {
  const WithdrawMethodsScreen({super.key});

  @override
  ConsumerState<WithdrawMethodsScreen> createState() => _WithdrawMethodsScreenState();
}

class _WithdrawMethodsScreenState extends ConsumerState<WithdrawMethodsScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _dynamicFormData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawControllerProvider.notifier).loadWithdrawMethods();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Decimal _calculateCharge(Decimal amount) {
    final currency = ref.read(withdrawControllerProvider).selectedCurrency;
    if (currency == null) return Decimal.zero;

    final fixed = currency.fixedChargeForSell;
    final percent = ((amount * currency.percentChargeForSell) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 8);
    return fixed + percent;
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = Decimal.tryParse(_amountController.text.trim());
    if (amount == null || amount <= Decimal.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid withdrawal amount')),
      );
      return;
    }

    final withdrawal = await ref.read(withdrawControllerProvider.notifier).submitWithdraw(
      amount: amount,
      formFields: _dynamicFormData,
    );

    if (!mounted) return;

    if (withdrawal != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Withdrawal Submitted'),
            ],
          ),
          content: Text(
            'Your withdrawal request of ${withdrawal.amount} has been received and is currently under processing.',
            style: AppTextTheme.bodyMedium,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/withdraw/history');
              },
              child: const Text('View History'),
            ),
          ],
        ),
      );
    } else {
      final error = ref.read(withdrawControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final userBalance = user?.balance ?? Decimal.zero;
    final selectedCurrency = state.selectedCurrency;

    // Platform Disabled Banner
    if (state.isWithdrawDisabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Withdraw Funds')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.p24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pause_circle_outline, size: 72, color: AppColors.warning),
                const SizedBox(height: 20),
                Text(
                  'Withdrawals Paused',
                  style: AppTextTheme.headingLarge.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.disabledMessage ?? 'Wallet withdrawals are temporarily disabled for platform maintenance.',
                  style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'View Withdrawal History',
                  onPressed: () => context.push('/withdraw/history'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final enteredAmount = Decimal.tryParse(_amountController.text.trim()) ?? Decimal.zero;
    final charge = _calculateCharge(enteredAmount);
    final finalReceived = enteredAmount > charge ? enteredAmount - charge : Decimal.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Withdrawal History',
            onPressed: () => context.push('/withdraw/history'),
          ),
        ],
      ),
      body: state.isLoading && state.currencies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Available Balance Card
                    CustomCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available Wallet Balance', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                '₦${userBalance.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.base),
                              ),
                            ],
                          ),
                          const Icon(Icons.account_balance_wallet, color: AppColors.base, size: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Method Selection
                    Text('Select Payout Currency / Method', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    for (final currency in state.currencies) ...[
                      WithdrawCurrencyCard(
                        currency: currency,
                        isSelected: selectedCurrency?.id == currency.id,
                        onTap: () {
                          ref.read(withdrawControllerProvider.notifier).selectCurrency(currency);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),

                    if (selectedCurrency != null) ...[
                      // Amount Field
                      Text('Withdrawal Amount (${selectedCurrency.curSym})', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AppTextField(
                        hint: '0.00',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            selectedCurrency.curSym,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.base),
                          ),
                        ),
                        suffixIcon: TextButton(
                          onPressed: () {
                            _amountController.text = userBalance.toString();
                            setState(() {});
                          },
                          child: const Text('MAX', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.base)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final parsed = Decimal.tryParse(val.trim());
                          if (parsed == null || parsed <= Decimal.zero) {
                            return 'Enter a valid amount';
                          }
                          if (parsed > userBalance) {
                            return 'Amount exceeds wallet balance';
                          }
                          if (parsed < selectedCurrency.minimumLimitForSell) {
                            return 'Min withdrawal is ${selectedCurrency.minimumLimitForSell} ${selectedCurrency.curSym}';
                          }
                          if (selectedCurrency.maximumLimitForSell > Decimal.zero &&
                              parsed > selectedCurrency.maximumLimitForSell) {
                            return 'Max withdrawal is ${selectedCurrency.maximumLimitForSell} ${selectedCurrency.curSym}';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Charges and Summary Box
                      CustomCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Fixed Fee', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
                                Text('${selectedCurrency.fixedChargeForSell} ${selectedCurrency.curSym}', style: AppTextTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Percent Fee', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
                                Text('${selectedCurrency.percentChargeForSell}%', style: AppTextTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Fee', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body)),
                                Text('${charge.toStringAsFixed(2)} ${selectedCurrency.curSym}', style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('You Receive', style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  '${finalReceived.toStringAsFixed(2)} ${selectedCurrency.curSym}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.success),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dynamic Beneficiary Details Form
                      if (selectedCurrency.userDetailsData != null) ...[
                        Text('Beneficiary Payout Details', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        DynamicFormBuilder(
                          schema: selectedCurrency.userDetailsData!,
                          onChanged: (data) {
                            _dynamicFormData.addAll(data);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Submit CTA
                      AppButton(
                        text: 'Submit Withdrawal',
                        isLoading: state.isLoading,
                        onPressed: _submitWithdrawal,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
