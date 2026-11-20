import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'EN';

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Fast & Transparent Multi-Currency Exchange',
      description:
          'Convert fiat and digital currencies with real-time market rates, crystal-clear fee breakdowns, and instant execution.',
      icon: Icons.currency_exchange_rounded,
      highlightColor: AppColors.base,
    ),
    OnboardingSlide(
      title: 'Instant Transfers to Benin & Nigeria',
      description:
          'Send payouts directly to MTN Mobile Money, Moov Money, Nigerian commercial banks, and OPay in minutes.',
      icon: Icons.flash_on_rounded,
      highlightColor: AppColors.info,
    ),
    OnboardingSlide(
      title: 'Bank-Grade Security & 24/7 Support',
      description:
          'Your assets are safeguarded with strict 2FA, biometric authentication, and a personal transaction security PIN.',
      icon: Icons.shield_rounded,
      highlightColor: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language toggle
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.p16),
            child: PopupMenuButton<String>(
              initialValue: _selectedLanguage,
              onSelected: (val) {
                setState(() => _selectedLanguage = val);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language,
                        size: 16, color: AppColors.heading),
                    const SizedBox(width: 6),
                    Text(
                      _selectedLanguage,
                      style: AppTextTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'EN', child: Text('English (EN)')),
                const PopupMenuItem(value: 'FR', child: Text('Français (FR)')),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.p24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Graphic
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.highlightColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 68,
                            color: slide.highlightColor,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTextTheme.headingLarge.copyWith(
                            fontSize: 24,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: AppTextTheme.bodyMedium.copyWith(
                            color: AppColors.body,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.base
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p32),
            // Action Buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
              child: Column(
                children: [
                  AppButton(
                    text: 'Get Started',
                    onPressed: () => context.go('/register'),
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  AppButton(
                    text: 'Sign In',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p24),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color highlightColor;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.highlightColor,
  });
}
