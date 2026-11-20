import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/transfers/data/models/bank_model.dart';

class BankPickerSheet extends StatefulWidget {
  final List<BankModel> banks;
  final BankModel? selectedBank;
  final ValueChanged<BankModel> onSelect;

  const BankPickerSheet({
    super.key,
    required this.banks,
    this.selectedBank,
    required this.onSelect,
  });

  @override
  State<BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<BankPickerSheet> {
  final _searchController = TextEditingController();
  List<BankModel> _filteredBanks = [];

  @override
  void initState() {
    super.initState();
    _filteredBanks = widget.banks;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredBanks = widget.banks;
      } else {
        final q = query.toLowerCase();
        _filteredBanks = widget.banks.where((bank) {
          return bank.name.toLowerCase().contains(q) ||
                 bank.code.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20, vertical: AppDimensions.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Bank / Provider',
                  style: AppTextTheme.headingMedium.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search bank by name or code...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Bank List
          Expanded(
            child: _filteredBanks.isEmpty
                ? Center(
                    child: Text(
                      'No matching banks found',
                      style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredBanks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, index) {
                      final bank = _filteredBanks[index];
                      final isSelected = widget.selectedBank?.code == bank.code;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bank.isOpay
                              ? AppColors.baseLight.withOpacity(0.2)
                              : AppColors.surfaceSubtle,
                          child: Icon(
                            bank.isOpay ? Icons.account_balance_wallet : Icons.account_balance,
                            color: bank.isOpay ? AppColors.base : AppColors.body,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          bank.name,
                          style: AppTextTheme.bodyLarge.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          bank.code.toUpperCase(),
                          style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.base)
                            : null,
                        onTap: () {
                          widget.onSelect(bank);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
