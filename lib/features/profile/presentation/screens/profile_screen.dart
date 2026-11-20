import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/language_selector_sheet.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/profile/data/repositories/profile_repository.dart';
import '../widgets/delete_account_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _firstnameController = TextEditingController(text: user?.firstname ?? '');
    _lastnameController = TextEditingController(text: user?.lastname ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _stateController = TextEditingController(text: user?.state ?? '');
    _zipController = TextEditingController(text: user?.zip ?? '');
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedUser = await ref.read(profileRepositoryProvider).updateProfile(
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
      );

      ref.read(authControllerProvider.notifier).setUser(updatedUser);

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of AYODEX?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.base),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.baseLight.withOpacity(0.2),
                    child: Text(
                      user?.firstname.isNotEmpty == true ? user!.firstname[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.base),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true ? user!.fullName : 'AYODEX User',
                          style: AppTextTheme.headingMedium.copyWith(fontSize: 18),
                        ),
                        Text(
                          '@${user?.username ?? 'user'}',
                          style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: user?.isKycVerified == true ? 'KYC Verified' : 'KYC Unverified',
                          color: user?.isKycVerified == true ? AppColors.success : AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information
            Text('Personal Information', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: CustomCard(
                child: Column(
                  children: [
                    // Read-only Username
                    AppTextField(
                      label: 'Username',
                      initialValue: user?.username ?? '',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Read-only Email
                    AppTextField(
                      label: 'Email Address',
                      initialValue: user?.email ?? '',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Read-only Mobile
                    AppTextField(
                      label: 'Mobile Number',
                      initialValue: '${user?.dialCode ?? ''} ${user?.mobile ?? ''}',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      suffixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Editable Names
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'First Name',
                            controller: _firstnameController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Last Name',
                            controller: _lastnameController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Address
                    AppTextField(
                      label: 'Address',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 14),

                    // City, State, Zip
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'City',
                            controller: _cityController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'State',
                            controller: _stateController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'Zip',
                            controller: _zipController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      text: 'Save Changes',
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Links
            Text('Security & Settings', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  _buildNavTile(
                    icon: Icons.language_outlined,
                    title: 'Language / Langue',
                    subtitle: 'Français & English',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const LanguageSelectorSheet(),
                    ),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.pin_outlined,
                    title: 'Transaction PIN',
                    subtitle: 'Manage 4-digit transfer PIN',
                    onTap: () => context.push('/security/pin'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.security_outlined,
                    title: '2FA Authenticator',
                    subtitle: 'Google Authenticator protection',
                    onTap: () => context.push('/security/2fa'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.verified_user_outlined,
                    title: 'KYC Identity Verification',
                    subtitle: 'View KYC compliance status',
                    onTap: () => context.push('/kyc/status'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.lock_reset_outlined,
                    title: 'Change Password',
                    subtitle: 'Update login password',
                    onTap: () => context.push('/profile/change-password'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.share_outlined,
                    title: 'Affiliate & Referrals',
                    subtitle: 'Earn commissions by inviting friends',
                    onTap: () => context.push('/affiliate'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.quiz_outlined,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    onTap: () => context.push('/faq'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.policy_outlined,
                    title: 'Legal & Privacy Policy',
                    subtitle: 'Terms of service and privacy',
                    onTap: () => context.push('/policies'),
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Contact Support',
                    subtitle: 'Reach out to the AYODEX team',
                    onTap: () => context.push('/contact'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            CustomCard(
              child: Column(
                children: [
                  _buildNavTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    titleColor: AppColors.body,
                    onTap: _handleLogout,
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildNavTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    titleColor: AppColors.danger,
                    subtitle: 'Permanently close your account',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const DeleteAccountDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.surfaceSubtle,
          child: Icon(icon, color: titleColor ?? AppColors.base, size: 20),
        ),
        title: Text(
          title,
          style: AppTextTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppColors.heading,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextTheme.caption.copyWith(color: AppColors.textMuted))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
