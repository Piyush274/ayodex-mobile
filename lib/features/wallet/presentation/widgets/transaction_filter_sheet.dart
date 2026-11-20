import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';

class TransactionFilterSheet extends StatefulWidget {
  final List<String> availableRemarks;
  final String? initialRemark;
  final ValueChanged<String?> onApply;

  const TransactionFilterSheet({
    super.key,
    required this.availableRemarks,
    this.initialRemark,
    required this.onApply,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late String? _selectedRemark;

  @override
  void initState() {
    super.initState();
    _selectedRemark = widget.initialRemark;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter by Remark', style: AppTextTheme.headingMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p16),
          if (widget.availableRemarks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.p20),
              child: Center(
                child: Text('No specific remarks available', style: AppTextTheme.bodyMedium),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Remarks'),
                  selected: _selectedRemark == null,
                  selectedColor: AppColors.base.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: _selectedRemark == null ? AppColors.base : AppColors.heading,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedRemark = null);
                  },
                ),
                ...widget.availableRemarks.map((remark) {
                  final isSelected = _selectedRemark == remark;
                  return ChoiceChip(
                    label: Text(remark.replaceAll('_', ' ').toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppColors.base.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.base : AppColors.heading,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedRemark = selected ? remark : null);
                    },
                  );
                }),
              ],
            ),
          const SizedBox(height: AppDimensions.p24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Reset',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    widget.onApply(null);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.p12),
              Expanded(
                child: AppButton(
                  text: 'Apply Filter',
                  onPressed: () {
                    widget.onApply(_selectedRemark);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p12),
        ],
      ),
    );
  }
}
