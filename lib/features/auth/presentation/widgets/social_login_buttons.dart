import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.p12),
              child: Text('OR CONTINUE WITH', style: AppTextTheme.caption),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppDimensions.p16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGoogleTap,
                icon:
                    const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                label: const Text('Google',
                    style: TextStyle(
                        color: AppColors.heading, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(AppDimensions.buttonHeight),
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMedium),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.p12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFacebookTap,
                icon: const Icon(Icons.facebook,
                    size: 22, color: Color(0xFF1877F2)),
                label: const Text('Facebook',
                    style: TextStyle(
                        color: AppColors.heading, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(AppDimensions.buttonHeight),
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMedium),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
