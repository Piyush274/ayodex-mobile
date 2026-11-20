import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/exchange/data/repositories/exchange_repository.dart';
import 'package:ayodex/features/exchange/data/models/exchange_model.dart';

class ExchangeTrackScreen extends ConsumerStatefulWidget {
  final String? initialExchangeId;

  const ExchangeTrackScreen({super.key, this.initialExchangeId});

  @override
  ConsumerState<ExchangeTrackScreen> createState() => _ExchangeTrackScreenState();
}

class _ExchangeTrackScreenState extends ConsumerState<ExchangeTrackScreen> {
  final _searchController = TextEditingController();
  ExchangeModel? _trackedExchange;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialExchangeId != null) {
      _searchController.text = widget.initialExchangeId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTrack();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleTrack() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(exchangeRepositoryProvider);
      final ex = await repo.trackExchange(query);
      setState(() {
        _trackedExchange = ex;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Exchange'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Header
              Text(
                'Track Your Order',
                style: AppTextTheme.displayLarge.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your unique Exchange ID to see real-time execution progress.',
                style: AppTextTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.p20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Exchange ID (e.g. EX123456)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleTrack(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p12),
                  SizedBox(
                    height: AppDimensions.inputHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.base),
                      onPressed: _handleTrack,
                      child: const Text('Track', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p24),

              // Loading Spinner
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.base))
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(_errorMessage!, style: AppTextTheme.bodyMedium.copyWith(color: AppColors.danger)),
                )
              else if (_trackedExchange != null) ...[
                // Tracking Stepper Card
                CustomCard(
                  title: 'Order Status',
                  trailing: StatusBadge(
                    label: _trackedExchange!.status == 1 ? 'Approved' : 'Processing',
                    color: _trackedExchange!.status == 1 ? AppColors.success : AppColors.warning,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StepItem(
                        title: 'Order Placed',
                        subtitle: 'Exchange order registered in the system',
                        isCompleted: true,
                      ),
                      _StepItem(
                        title: 'Payment Received',
                        subtitle: 'Deposit received or gateway verified',
                        isCompleted: _trackedExchange!.status >= 1,
                      ),
                      _StepItem(
                        title: 'Processing Payout',
                        subtitle: 'Transferring to destination account',
                        isCompleted: _trackedExchange!.status >= 1,
                      ),
                      _StepItem(
                        title: 'Completed',
                        subtitle: 'Funds successfully credited',
                        isCompleted: _trackedExchange!.status == 1,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  const _StepItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.success : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.surfaceSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: color),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 14,
                color: isCompleted ? Colors.white : AppColors.textMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.heading : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
