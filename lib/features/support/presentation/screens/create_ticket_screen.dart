import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_button.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import 'package:ayodex/features/support/presentation/controllers/ticket_controller.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _selectedPriority = 2; // 1=Low, 2=Medium, 3=High
  final List<UploadedFile> _attachments = [];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ticket = await ref.read(ticketControllerProvider.notifier).createTicket(
      subject: _subjectController.text.trim(),
      priority: _selectedPriority,
      message: _messageController.text.trim(),
      attachments: _attachments.isNotEmpty ? _attachments : null,
    );

    if (!mounted) return;

    if (ticket != null) {
      context.go('/support/view/${ticket.ticket}');
    } else {
      final error = ref.read(ticketControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open New Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subject Field
              AppTextField(
                label: 'Subject',
                hint: 'e.g. Question about deposit or transfer',
                controller: _subjectController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a ticket subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Priority Selector
              Text('Priority', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildPriorityOption('Low', 1),
                    _buildPriorityOption('Medium', 2),
                    _buildPriorityOption('High', 3),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message Field
              AppTextField(
                label: 'Message',
                hint: 'Describe your issue in detail...',
                controller: _messageController,
                maxLines: 5,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Attachments Header & Card
              Text('Attachments (Optional, max 5 files)', style: AppTextTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FileUploadCard(
                label: 'Attach File (JPG, PNG, PDF, DOC)',
                onFileSelected: (file) {
                  if (file != null && _attachments.length < 5) {
                    setState(() => _attachments.add(file));
                  }
                },
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Column(
                  children: _attachments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_file, size: 16, color: AppColors.base),
                              const SizedBox(width: 8),
                              Text(file.name, style: AppTextTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          InkWell(
                            onTap: () => setState(() => _attachments.removeAt(idx)),
                            child: const Icon(Icons.close, size: 16, color: AppColors.danger),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                text: 'Submit Ticket',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label, int value) {
    final isSelected = _selectedPriority == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = value),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium - 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium - 2),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: AppTextTheme.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.base : AppColors.body,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
