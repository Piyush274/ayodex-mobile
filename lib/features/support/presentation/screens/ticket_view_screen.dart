import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import 'package:ayodex/core/widgets/status_badge.dart';
import 'package:ayodex/features/support/data/models/ticket_model.dart';
import 'package:ayodex/features/support/presentation/controllers/ticket_controller.dart';

class TicketViewScreen extends ConsumerStatefulWidget {
  final String ticketNumber;

  const TicketViewScreen({super.key, required this.ticketNumber});

  @override
  ConsumerState<TicketViewScreen> createState() => _TicketViewScreenState();
}

class _TicketViewScreenState extends ConsumerState<TicketViewScreen> {
  final _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<UploadedFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketControllerProvider.notifier).loadTicketView(widget.ticketNumber);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    final ticket = ref.read(ticketControllerProvider).currentTicket;
    if (ticket == null) return;

    final success = await ref.read(ticketControllerProvider.notifier).replyTicket(
      ticketId: ticket.id,
      message: text,
      attachments: _attachments.isNotEmpty ? _attachments : null,
    );

    if (success) {
      _replyController.clear();
      setState(() => _attachments.clear());
      _scrollToBottom();
    }
  }

  Future<void> _confirmCloseTicket() async {
    final ticket = ref.read(ticketControllerProvider).currentTicket;
    if (ticket == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Support Ticket'),
        content: const Text('Are you sure you want to close this ticket?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Close Ticket'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(ticketControllerProvider.notifier).closeTicket(ticket.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketControllerProvider);
    final ticket = state.currentTicket;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${widget.ticketNumber}'),
        actions: [
          if (ticket != null && !ticket.isClosed)
            TextButton(
              onPressed: _confirmCloseTicket,
              child: const Text('Close', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: state.isLoading && ticket == null
          ? const Center(child: CircularProgressIndicator())
          : ticket == null
              ? const Center(child: Text('Ticket not found'))
              : Column(
                  children: [
                    // Ticket Meta Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: 12),
                      color: AppColors.surfaceSubtle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.subject,
                                  style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text('Priority: ${ticket.priorityLabel}', style: AppTextTheme.caption.copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: ticket.statusLabel,
                            color: ticket.isClosed ? AppColors.textMuted : AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Messages Thread
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        itemCount: ticket.messages.length,
                        itemBuilder: (context, index) {
                          final msg = ticket.messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
                    ),

                    // Reply Bar (If not closed)
                    if (ticket.isClosed)
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        color: AppColors.surfaceSubtle,
                        child: Center(
                          child: Text(
                            'This ticket has been closed. Open a new ticket if you need further help.',
                            style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      _buildReplyBar(state.isSubmitting),
                  ],
                ),
    );
  }

  Widget _buildMessageBubble(TicketMessageModel msg) {
    final isCustomer = msg.isCustomerMessage;
    final dateStr = msg.createdAt != null
        ? DateFormat('hh:mm a • MMM dd').format(msg.createdAt!)
        : '';

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCustomer ? AppColors.base.withOpacity(0.12) : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isCustomer ? 12 : 0),
            bottomRight: Radius.circular(isCustomer ? 0 : 12),
          ),
          border: Border.all(
            color: isCustomer ? AppColors.base.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCustomer ? 'You' : 'Support Agent',
                  style: AppTextTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCustomer ? AppColors.base : AppColors.heading,
                  ),
                ),
                const SizedBox(width: 8),
                Text(dateStr, style: AppTextTheme.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 6),
            Text(msg.message, style: AppTextTheme.bodyMedium),

            // Attachments
            if (msg.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.attachments.map((att) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file, size: 14, color: AppColors.base),
                        const SizedBox(width: 4),
                        Text('Attachment #${att.id}', style: AppTextTheme.caption),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar(bool isSubmitting) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 14, color: AppColors.base),
                  const SizedBox(width: 4),
                  Text('${_attachments.length} attachment(s) selected', style: AppTextTheme.caption),
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() => _attachments.clear()),
                    child: const Icon(Icons.close, size: 14, color: AppColors.danger),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: AppColors.textMuted),
                onPressed: () {
                  // File picker sheet or mock file addition
                  setState(() {
                    _attachments.add(UploadedFile(
                      name: 'attachment_${_attachments.length + 1}.png',
                      path: '',
                      bytes: 1024,
                    ));
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, color: AppColors.base),
                onPressed: isSubmitting ? null : _sendReply,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
