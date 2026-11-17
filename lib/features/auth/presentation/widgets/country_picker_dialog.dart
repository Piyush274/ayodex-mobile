import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/models/country_model.dart';
import 'package:ayodex/core/theme/text_theme.dart';

class CountryPickerDialog extends StatefulWidget {
  final List<CountryModel> countries;
  final ValueChanged<CountryModel> onCountrySelected;

  const CountryPickerDialog({
    super.key,
    required this.countries,
    required this.onCountrySelected,
  });

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<CountryModel> _filteredCountries;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prioritize Benin (BJ) and Nigeria (NG)
    final priority = widget.countries.where((c) => c.countryCode == 'BJ' || c.countryCode == 'NG').toList();
    final others = widget.countries.where((c) => c.countryCode != 'BJ' && c.countryCode != 'NG').toList();
    _filteredCountries = [...priority, ...others];
  }

  void _filter(String query) {
    if (query.isEmpty) {
      final priority = widget.countries.where((c) => c.countryCode == 'BJ' || c.countryCode == 'NG').toList();
      final others = widget.countries.where((c) => c.countryCode != 'BJ' && c.countryCode != 'NG').toList();
      setState(() => _filteredCountries = [...priority, ...others]);
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredCountries = widget.countries.where((c) {
        return c.country.toLowerCase().contains(lower) ||
            c.dialCode.contains(query) ||
            c.countryCode.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusCard),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Country', style: AppTextTheme.headingMedium),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p8),
              TextField(
                controller: _searchController,
                onChanged: _filter,
                decoration: const InputDecoration(
                  hintText: 'Search by country or code...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: AppDimensions.p12),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredCountries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredCountries[index];
                    final isPriority = item.countryCode == 'BJ' || item.countryCode == 'NG';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPriority ? AppColors.base.withOpacity(0.12) : AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isPriority ? AppColors.base : AppColors.border,
                          ),
                        ),
                        child: Text(
                          item.countryCode,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isPriority ? AppColors.base : AppColors.heading,
                          ),
                        ),
                      ),
                      title: Text(item.country, style: AppTextTheme.bodyLarge),
                      trailing: Text('+${item.dialCode}', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      onTap: () {
                        widget.onCountrySelected(item);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
