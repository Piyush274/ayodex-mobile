import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ayodex/features/profile/data/repositories/profile_repository.dart';

class AffiliateScreen extends ConsumerStatefulWidget {
  const AffiliateScreen({super.key});

  @override
  ConsumerState<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends ConsumerState<AffiliateScreen> {
  Map<String, dynamic>? _affiliateData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAffiliateData();
  }

  Future<void> _loadAffiliateData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(profileRepositoryProvider).getAffiliateData();
      if (mounted) {
        setState(() {
          _affiliateData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final username = user?.username ?? '';
    final referralUrl = 'https://ayodex.com?reference=$username';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliate & Referrals'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Referral Link Banner
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Referral Link', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Share your link with friends. Earn commissions on their currency exchanges and payouts.',
                          style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: AppColors.base, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  referralUrl,
                                  style: AppTextTheme.caption.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: referralUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Referral link copied to clipboard!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                child: const Icon(Icons.copy, color: AppColors.base, size: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Copy Referral Link',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: referralUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral link copied to clipboard!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Referral Metrics
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Referrals', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                '${_affiliateData?['total_referrals'] ?? 0}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.base),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Commissions Earned', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                '₦${_affiliateData?['total_commissions'] ?? '0.00'}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Commission Logs Header
                  Text('Commission History', style: AppTextTheme.headingMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.group_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No commission logs yet', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'When your referrals trade, your commissions will appear here.',
                            style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
