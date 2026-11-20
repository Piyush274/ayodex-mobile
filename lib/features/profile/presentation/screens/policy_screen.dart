import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/features/profile/data/repositories/profile_repository.dart';

class PolicyScreen extends ConsumerStatefulWidget {
  final String? slug;

  const PolicyScreen({super.key, this.slug});

  @override
  ConsumerState<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends ConsumerState<PolicyScreen> {
  List<Map<String, dynamic>> _policies = [];
  Map<String, dynamic>? _selectedPolicy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicyData();
  }

  Future<void> _loadPolicyData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.slug != null && widget.slug!.isNotEmpty) {
        final policy = await ref.read(profileRepositoryProvider).getPolicyContent(widget.slug!);
        if (mounted) {
          setState(() {
            _selectedPolicy = policy;
            _isLoading = false;
          });
        }
      } else {
        final policies = await ref.read(profileRepositoryProvider).getPolicies();
        if (mounted) {
          setState(() {
            _policies = policies;
            if (policies.isNotEmpty) {
              _selectedPolicy = policies.first;
            }
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPolicy?['data_values']?['title'] ?? 'Legal & Privacy Policies'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tab pills if multiple policies
                  if (_policies.length > 1) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _policies.map((p) {
                          final title = p['data_values']?['title'] ?? p['slug'] ?? 'Policy';
                          final isSelected = _selectedPolicy?['id'] == p['id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(title),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedPolicy = p),
                              selectedColor: AppColors.baseLight.withOpacity(0.2),
                              checkmarkColor: AppColors.base,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.base : AppColors.body,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Policy Content Card
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPolicy?['data_values']?['title'] ?? 'Terms & Conditions',
                          style: AppTextTheme.headingLarge.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Text(
                          _cleanContent(_selectedPolicy?['data_values']?['details'] ??
                              'AYODEX is committed to providing a secure, compliant, and transparent digital exchange platform. Users must adhere to international AML and CFT regulations when conducting transactions.'),
                          style: AppTextTheme.bodyMedium.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _cleanContent(String rawHtml) {
    return rawHtml
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
