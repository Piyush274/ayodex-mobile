import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/profile/data/repositories/profile_repository.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _faqs = [];
  List<Map<String, dynamic>> _filteredFaqs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFaqs() async {
    setState(() => _isLoading = true);
    try {
      final faqs = await ref.read(profileRepositoryProvider).getFaqs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _filteredFaqs = faqs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        // Fallback default FAQs
        final defaultFaqs = [
          {
            'data_values': {
              'question': 'How long does a currency exchange take to process?',
              'answer': 'Automatic exchanges are settled within 1 to 5 minutes. Manual deposit verification usually takes 10 to 30 minutes.'
            }
          },
          {
            'data_values': {
              'question': 'What are the transfer fees to Benin MTN/Moov and Nigerian banks?',
              'answer': 'Each payout provider specifies a minimal fixed and percentage transaction fee shown in real-time on the transfer preview screen.'
            }
          },
          {
            'data_values': {
              'question': 'Is KYC mandatory to send or withdraw funds?',
              'answer': 'Yes, to comply with regional anti-money laundering regulations, KYC verification is required prior to initiating wallet payouts and withdrawals.'
            }
          },
        ];
        setState(() {
          _faqs = defaultFaqs;
          _filteredFaqs = defaultFaqs;
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredFaqs = _faqs);
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredFaqs = _faqs.where((f) {
          final question = f['data_values']?['question']?.toString().toLowerCase() ?? '';
          final answer = f['data_values']?['answer']?.toString().toLowerCase() ?? '';
          return question.contains(q) || answer.contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // FAQ List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFaqs.isEmpty
                    ? Center(
                        child: Text(
                          'No matching questions found',
                          style: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        itemCount: _filteredFaqs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _filteredFaqs[index];
                          final question = item['data_values']?['question'] ?? 'Question';
                          final answer = item['data_values']?['answer'] ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                question,
                                style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    answer,
                                    style: AppTextTheme.bodyMedium.copyWith(color: AppColors.body, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
