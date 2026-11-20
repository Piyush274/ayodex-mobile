import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/localization/localization_repository.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';

class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p20,
        vertical: AppDimensions.p24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Select Language / Sélectionner la langue',
              style: AppTextTheme.headingMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose your preferred language for the app',
              style: AppTextTheme.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(
              context: context,
              ref: ref,
              code: 'fr',
              flagEmoji: '🇫🇷',
              title: 'Français',
              subtitle: 'Bénin, Togo, France (Par défaut)',
              isSelected: currentLocale.languageCode == 'fr',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              ref: ref,
              code: 'en',
              flagEmoji: '🇬🇧',
              title: 'English',
              subtitle: 'Nigeria, Ghana, Global',
              isSelected: currentLocale.languageCode == 'en',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String code,
    required String flagEmoji,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(currentLocaleProvider.notifier).setLocale(code);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.base.withOpacity(0.12)
                    : AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Text(
                flagEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextTheme.headingSmall.copyWith(
                      fontSize: 16,
                      color: isSelected ? AppColors.base : AppColors.heading,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextTheme.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.base,
                size: 22,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.textMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
