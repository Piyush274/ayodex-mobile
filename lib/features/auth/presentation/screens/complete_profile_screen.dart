import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/constants/app_strings.dart';
import 'package:ayodex/core/models/country_model.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/country_picker_dialog.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  CountryModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final countries = ref.read(authControllerProvider).countries;
      if (countries.isNotEmpty) {
        // Default to Benin (BJ) or first
        final benin = countries.firstWhere(
          (c) => c.countryCode == 'BJ',
          orElse: () => countries.first,
        );
        setState(() => _selectedCountry = benin);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _openCountryPicker() {
    final countries = ref.read(authControllerProvider).countries;
    if (countries.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => CountryPickerDialog(
        countries: countries,
        onCountrySelected: (c) {
          setState(() => _selectedCountry = c);
        },
      ),
    );
  }

  Future<void> _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your country')),
      );
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);
    final success = await authNotifier.completeProfile(
      countryCode: _selectedCountry!.countryCode,
      country: _selectedCountry!.country,
      mobileCode: _selectedCountry!.dialCode,
      username: _usernameController.text.trim().toLowerCase(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      stateName: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      zip: _zipController.text.trim().isEmpty ? null : _zipController.text.trim(),
    );

    if (mounted && success) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Profile Setup'),
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: Text(
                'Logout',
                style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.p24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Almost There!',
                    style: AppTextTheme.displayLarge.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: AppDimensions.p8),
                  Text(
                    'To comply with financial regulations and secure your wallet, please complete your profile details.',
                    style: AppTextTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.p24),

                  // Error banner
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                          const SizedBox(width: AppDimensions.p8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),
                  ],

                  // Country Picker Trigger
                  Text(
                    'Country',
                    style: AppTextTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p8),
                  InkWell(
                    onTap: _openCountryPicker,
                    borderRadius: AppDimensions.borderRadiusMedium,
                    child: Container(
                      height: AppDimensions.inputHeight,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppDimensions.borderRadiusMedium,
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          if (_selectedCountry != null) ...[
                            Text(
                              _selectedCountry!.flagEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                '${_selectedCountry!.country} (+${_selectedCountry!.dialCode})',
                                style: AppTextTheme.bodyLarge.copyWith(color: AppColors.heading),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: Text(
                                'Select your country',
                                style: AppTextTheme.bodyLarge.copyWith(color: AppColors.textMuted),
                              ),
                            ),
                          ],
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Mobile Number
                  AppTextField(
                    key: const Key('profile_mobile'),
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hint: '97000000',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      width: 60,
                      child: Text(
                        _selectedCountry != null ? '+${_selectedCountry!.dialCode}' : '+',
                        style: AppTextTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mobile number is required';
                      }
                      if (value.trim().length < 6) {
                        return 'Enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Username
                  AppTextField(
                    key: const Key('profile_username'),
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'e.g. john_doe',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 6) {
                        return 'Username must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Address
                  AppTextField(
                    key: const Key('profile_address'),
                    controller: _addressController,
                    label: 'Street Address',
                    hint: 'e.g. 123 Rue de la Paix',
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // City and State Row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          key: const Key('profile_city'),
                          controller: _cityController,
                          label: 'City',
                          hint: 'Cotonou',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: AppTextField(
                          key: const Key('profile_state'),
                          controller: _stateController,
                          label: 'State / Region',
                          hint: 'Littoral',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Zip Code
                  AppTextField(
                    key: const Key('profile_zip'),
                    controller: _zipController,
                    label: 'Zip / Postal Code',
                    hint: '00229',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: AppDimensions.p32),

                  // Submit Button
                  AppButton(
                    text: 'Complete Profile',
                    isLoading: authState.isLoading,
                    onPressed: _handleCompleteProfile,
                  ),
                  const SizedBox(height: AppDimensions.p24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
