import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/bank_picker_sheet.dart';

class TransferNewScreen extends ConsumerStatefulWidget {
  const TransferNewScreen({super.key});

  @override
  ConsumerState<TransferNewScreen> createState() => _TransferNewScreenState();
}

class _TransferNewScreenState extends ConsumerState<TransferNewScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transferControllerProvider.notifier).loadBanks();
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAccountChanged(String value) {
    if (value.trim().length >= 10) {
      ref.read(transferControllerProvider.notifier).resolveAccount(value.trim());
    }
  }

  void _openBankPicker() {
    final state = ref.read(transferControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BankPickerSheet(
        banks: state.banks,
        selectedBank: state.selectedBank,
        onSelect: (bank) {
          ref.read(transferControllerProvider.notifier).selectBank(bank);
          if (_accountController.text.trim().length >= 10) {
            ref.read(transferControllerProvider.notifier).resolveAccount(_accountController.text.trim());
          }
        },
      ),
    );
  }

  Future<void> _handleGetQuote() async {
    if (!_formKey.currentState!.validate()) return;

    final amountDec = Decimal.tryParse(_amountController.text.trim());
    if (amountDec == null || amountDec <= Decimal.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final quote = await ref.read(transferControllerProvider.notifier).createQuote(
      accountNumber: _accountController.text.trim(),
      amount: amountDec,
    );

    if (quote != null && mounted) {
      context.push('/transfer/quote/${quote.quoteId}');
    } else if (mounted) {
      final error = ref.read(transferControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final userBalance = user?.balance ?? Decimal.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Transfer History',
            onPressed: () => context.push('/transfer/history'),
          ),
        ],
      ),
      body: state.isLoading && state.banks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Destination Type Segmented Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSegmentButton(
                              label: 'Commercial Bank',
                              icon: Icons.account_balance,
                              isSelected: state.destinationType == 'bank',
                              onTap: () {
                                ref.read(transferControllerProvider.notifier).selectDestinationType('bank');
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildSegmentButton(
                              label: 'OPay Wallet',
                              icon: Icons.account_balance_wallet,
                              isSelected: state.destinationType == 'opay_wallet',
                              onTap: () {
                                ref.read(transferControllerProvider.notifier).selectDestinationType('opay_wallet');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bank Selector
                    Text('Destination Bank / Provider', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _openBankPicker,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.surfaceSubtle,
                                  child: Icon(
                                    state.destinationType == 'opay_wallet'
                                        ? Icons.account_balance_wallet
                                        : Icons.account_balance,
                                    size: 16,
                                    color: AppColors.base,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state.selectedBank?.name ?? 'Select Bank / Provider',
                                  style: AppTextTheme.bodyLarge.copyWith(
                                    color: state.selectedBank != null ? AppColors.heading : AppColors.textMuted,
                                    fontWeight: state.selectedBank != null ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipient Account Number
                    AppTextField(
                      label: state.destinationType == 'opay_wallet' ? 'OPay Phone / Account Number' : 'Recipient Account Number',
                      hint: '10-digit account number',
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      onChanged: _onAccountChanged,
                      prefixIcon: const Icon(Icons.numbers),
                      suffixIcon: state.isResolvingAccount
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter account number';
                        }
                        if (val.trim().length < 10) {
                          return 'Account number must be 10 digits';
                        }
                        return null;
                      },
                    ),

                    // Verified Beneficiary Banner
                    if (state.resolvedAccountName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verified Beneficiary Name',
                                    style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                                  ),
                                  Text(
                                    state.resolvedAccountName!,
                                    style: AppTextTheme.bodyMedium.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // Transfer Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transfer Amount (NGN)', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          'Available: ₦${userBalance.toStringAsFixed(2)}',
                          style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      hint: '0.00',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Text(
                          '₦',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.base),
                        ),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          _amountController.text = userBalance.toString();
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
                          return 'Insufficient wallet balance';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit CTA
                    AppButton(
                      text: 'Get Transfer Quote',
                      isLoading: state.isLoading,
                      onPressed: state.isResolvingAccount ? null : _handleGetQuote,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.base : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextTheme.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.base : AppColors.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
