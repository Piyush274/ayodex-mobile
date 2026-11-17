import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/text_theme.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_text_field.dart';
import 'core/widgets/custom_card.dart';
import 'core/widgets/status_badge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AyodexApp());
}

class AyodexApp extends StatelessWidget {
  const AyodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ThemeShowcaseScreen(),
    );
  }
}

class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppDimensions.p16),
            child: StatusBadge(
              label: 'Step 1 Ready',
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'AYODEX Theme & Design System',
              style: AppTextTheme.headingLarge,
            ),
            const SizedBox(height: AppDimensions.p4),
            Text(
              'Mirrors the active "orange_oasis" website styling tokens.',
              style: AppTextTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.p20),

            // Color Swatches Card
            CustomCard(
              title: 'Brand Palette',
              child: Wrap(
                spacing: AppDimensions.p12,
                runSpacing: AppDimensions.p12,
                children: const [
                  _ColorChip(name: 'Base Orange', color: AppColors.base, hex: '#FF6033'),
                  _ColorChip(name: 'Accent Obsidian', color: AppColors.accent, hex: '#110226'),
                  _ColorChip(name: 'Heading Slate', color: AppColors.heading, hex: '#353A69'),
                  _ColorChip(name: 'Body Grey', color: AppColors.body, hex: '#515E80'),
                  _ColorChip(name: 'Success', color: AppColors.success, hex: '#28C76F'),
                  _ColorChip(name: 'Danger', color: AppColors.danger, hex: '#EA5455'),
                  _ColorChip(name: 'Warning', color: AppColors.warning, hex: '#FF9F43'),
                  _ColorChip(name: 'Info', color: AppColors.info, hex: '#1DA1F2'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),

            // Status Badges
            CustomCard(
              title: 'Status Pills',
              child: Wrap(
                spacing: AppDimensions.p8,
                runSpacing: AppDimensions.p8,
                children: const [
                  StatusBadge(label: 'Approved', color: AppColors.success, icon: Icons.check_circle),
                  StatusBadge(label: 'Pending', color: AppColors.warning, icon: Icons.hourglass_top),
                  StatusBadge(label: 'Processing', color: AppColors.info, icon: Icons.sync),
                  StatusBadge(label: 'Canceled', color: AppColors.danger, icon: Icons.cancel),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),

            // Input Fields Card
            CustomCard(
              title: 'Form Inputs',
              child: Column(
                children: [
                  AppTextField(
                    label: AppStrings.emailOrUsername,
                    hint: 'user@example.com or username',
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: AppDimensions.p16),
                  AppTextField(
                    label: AppStrings.password,
                    hint: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),

            // Action Buttons Card
            CustomCard(
              title: 'Button Variants',
              child: Column(
                children: [
                  AppButton(
                    text: 'Primary Base Button',
                    variant: AppButtonVariant.primary,
                    icon: Icons.currency_exchange,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  AppButton(
                    text: 'Secondary Accent Button',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  AppButton(
                    text: 'Outline Button',
                    variant: AppButtonVariant.outline,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  const AppButton(
                    text: 'Loading Button',
                    isLoading: true,
                    onPressed: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p32),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;

  const _ColorChip({
    required this.name,
    required this.color,
    required this.hex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppDimensions.p8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppDimensions.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  hex,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
