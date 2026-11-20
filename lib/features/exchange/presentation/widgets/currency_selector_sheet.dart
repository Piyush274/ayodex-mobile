import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';

class CurrencySelectorSheet extends StatefulWidget {
  final String title;
  final List<CurrencyModel> currencies;
  final CurrencyModel? selectedCurrency;
  final ValueChanged<CurrencyModel> onSelect;

  const CurrencySelectorSheet({
    super.key,
    required this.title,
    required this.currencies,
    this.selectedCurrency,
    required this.onSelect,
  });

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  final _searchController = TextEditingController();
  late List<CurrencyModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.currencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filtered = widget.currencies);
      return;
    }
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = widget.currencies.where((c) {
        return c.name.toLowerCase().contains(q) || c.curSym.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTextTheme.headingMedium),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search currency name or code...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: _filter,
            ),
            const SizedBox(height: AppDimensions.p16),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('No matching currencies found', style: AppTextTheme.bodyMedium),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final currency = _filtered[index];
                        final isSelected = widget.selectedCurrency?.id == currency.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.base.withOpacity(0.12),
                            child: Text(
                              currency.curSym.isNotEmpty ? currency.curSym.substring(0, 1) : '\$',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.base),
                            ),
                          ),
                          title: Text(currency.name, style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text('Reserve: ${currency.reserve} ${currency.curSym}', style: AppTextTheme.caption),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.base)
                              : Text(currency.curSym, style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          onTap: () {
                            widget.onSelect(currency);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
