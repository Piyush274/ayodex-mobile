import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/custom_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/support/data/models/ticket_model.dart';
import 'package:ayodex/features/support/presentation/controllers/ticket_controller.dart';

class SupportTicketsScreen extends ConsumerStatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  ConsumerState<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketControllerProvider.notifier).loadTickets(refresh: true);
    });
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return AppColors.success; // Open
      case 1:
        return AppColors.info; // Answered
      case 2:
        return AppColors.warning; // Customer Reply
      case 3:
        return AppColors.textMuted; // Closed
      default:
        return AppColors.base;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.info; // Low
      case 2:
        return AppColors.warning; // Medium
      case 3:
        return AppColors.danger; // High
      default:
        return AppColors.base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create'),
        backgroundColor: AppColors.base,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Open Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(ticketControllerProvider.notifier).loadTickets(refresh: true);
        },
        child: state.isLoading && state.tickets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.support_agent_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text('No support tickets', style: AppTextTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Need help? Open a new ticket anytime.',
                          style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    itemCount: state.tickets.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.tickets.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () {
                              ref.read(ticketControllerProvider.notifier).loadTickets();
                            },
                            child: const Text('Load More'),
                          ),
                        );
                      }

                      final ticket = state.tickets[index];
                      final dateStr = ticket.lastReply != null
                          ? DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.lastReply!)
                          : ticket.createdAt != null
                              ? DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt!)
                              : 'N/A';

                      return CustomCard(
                        onTap: () => context.push('/support/view/${ticket.ticket}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '[Ticket #${ticket.ticket}]',
                                  style: AppTextTheme.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.base,
                                  ),
                                ),
                                Row(
                                  children: [
                                    StatusBadge(
                                      label: ticket.priorityLabel,
                                      color: _getPriorityColor(ticket.priority),
                                    ),
                                    const SizedBox(width: 6),
                                    StatusBadge(
                                      label: ticket.statusLabel,
                                      color: _getStatusColor(ticket.status),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.subject,
                              style: AppTextTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Last Reply: $dateStr',
                                  style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
