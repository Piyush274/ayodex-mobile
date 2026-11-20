import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/features/transfers/data/models/transfer_model.dart';

class TransferStatusTimeline extends StatelessWidget {
  final List<TransferEventModel> events;
  final String currentStatus;

  const TransferStatusTimeline({
    super.key,
    required this.events,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    // If no explicit events from server, synthesize default lifecycle stages
    final displayEvents = events.isNotEmpty
        ? events
        : _synthesizeEvents(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayEvents.length; i++) ...[
          _TimelineItem(
            event: displayEvents[i],
            isLast: i == displayEvents.length - 1,
            isActive: i == displayEvents.length - 1,
          ),
        ],
      ],
    );
  }

  List<TransferEventModel> _synthesizeEvents(String status) {
    final list = <TransferEventModel>[
      TransferEventModel(
        status: 'initiated',
        note: 'Transfer request submitted and debited from wallet',
        createdAt: DateTime.now(),
      ),
    ];

    if (status == 'processing') {
      list.add(TransferEventModel(
        status: 'processing',
        note: 'Dispatched to provider banking gateway',
        createdAt: DateTime.now(),
      ));
    } else if (status == 'success') {
      list.add(TransferEventModel(
        status: 'processing',
        note: 'Dispatched to provider banking gateway',
        createdAt: DateTime.now(),
      ));
      list.add(TransferEventModel(
        status: 'success',
        note: 'Funds delivered to beneficiary bank account',
        createdAt: DateTime.now(),
      ));
    } else if (status.contains('fail') || status.contains('refund')) {
      list.add(TransferEventModel(
        status: 'processing',
        note: 'Sent to gateway',
        createdAt: DateTime.now(),
      ));
      list.add(TransferEventModel(
        status: 'failed_refunded',
        note: 'Beneficiary bank declined. Funds refunded to wallet.',
        createdAt: DateTime.now(),
      ));
    }

    return list;
  }
}

class _TimelineItem extends StatelessWidget {
  final TransferEventModel event;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.isActive,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'failed_refunded':
      case 'failed':
        return AppColors.danger;
      default:
        return AppColors.base;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_top;
      case 'failed_refunded':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.radio_button_checked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(event.status);
    final icon = _getStatusIcon(event.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon & Line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 16),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.p12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTitle(event.status),
                        style: AppTextTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.heading : AppColors.body,
                        ),
                      ),
                      if (event.createdAt != null)
                        Text(
                          DateFormat('hh:mm a').format(event.createdAt!),
                          style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  if (event.note != null && event.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.note!,
                      style: AppTextTheme.caption.copyWith(color: AppColors.body),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTitle(String status) {
    switch (status.toLowerCase()) {
      case 'initiated':
        return 'Transfer Initiated';
      case 'processing':
        return 'Processing with Bank';
      case 'success':
        return 'Funds Delivered Successfully';
      case 'failed_refunded':
        return 'Transfer Failed & Refunded';
      case 'manual_review':
        return 'Under Manual Review';
      default:
        return status.toUpperCase();
    }
  }
}
