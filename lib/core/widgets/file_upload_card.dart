import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_theme.dart';

class UploadedFile {
  final String name;
  final String path;
  final int bytes;

  const UploadedFile({
    required this.name,
    required this.path,
    this.bytes = 0,
  });
}

class FileUploadCard extends StatefulWidget {
  final String label;
  final String? instruction;
  final List<String> allowedExtensions;
  final bool isRequired;
  final UploadedFile? initialFile;
  final ValueChanged<UploadedFile?>? onFileSelected;
  final FormFieldValidator<UploadedFile>? validator;

  const FileUploadCard({
    super.key,
    required this.label,
    this.instruction,
    this.allowedExtensions = const [],
    this.isRequired = false,
    this.initialFile,
    this.onFileSelected,
    this.validator,
  });

  @override
  State<FileUploadCard> createState() => _FileUploadCardState();
}

class _FileUploadCardState extends State<FileUploadCard> {
  UploadedFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  void _pickMockFile() {
    // Allows picking/simulating a document attachment seamlessly
    final ext = widget.allowedExtensions.isNotEmpty ? widget.allowedExtensions.first : 'jpg';
    final mockName = 'document_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final mockFile = UploadedFile(
      name: mockName,
      path: '/simulated/documents/$mockName',
      bytes: 1024 * 350, // 350 KB
    );

    setState(() => _selectedFile = mockFile);
    widget.onFileSelected?.call(mockFile);
  }

  void _removeFile() {
    setState(() => _selectedFile = null);
    widget.onFileSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<UploadedFile>(
      initialValue: _selectedFile,
      validator: (val) {
        if (widget.isRequired && _selectedFile == null) {
          return '${widget.label} is required';
        }
        return widget.validator?.call(_selectedFile);
      },
      builder: (formState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                ),
                if (widget.isRequired)
                  Text(
                    ' *',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            if (widget.instruction != null && widget.instruction!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.instruction!,
                style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: AppDimensions.p8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: formState.hasError
                      ? AppColors.danger
                      : _selectedFile != null
                          ? AppColors.base
                          : AppColors.border,
                  width: _selectedFile != null ? 1.5 : 1,
                ),
                color: _selectedFile != null
                    ? AppColors.base.withOpacity(0.04)
                    : AppColors.surface,
              ),
              child: _selectedFile == null
                  ? InkWell(
                      onTap: () {
                        _pickMockFile();
                        formState.didChange(_selectedFile);
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p16,
                          vertical: AppDimensions.p16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: AppColors.base, size: 24),
                            const SizedBox(width: AppDimensions.p12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tap to upload document',
                                  style: AppTextTheme.bodyMedium.copyWith(
                                    color: AppColors.base,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.allowedExtensions.isNotEmpty)
                                  Text(
                                    'Supported: ${widget.allowedExtensions.join(', ').toUpperCase()}',
                                    style: AppTextTheme.caption,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(AppDimensions.p12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.base.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: const Icon(Icons.insert_drive_file, color: AppColors.base),
                          ),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ready to upload (${(_selectedFile!.bytes / 1024).toStringAsFixed(1)} KB)',
                                  style: AppTextTheme.caption.copyWith(color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.danger, size: 20),
                            onPressed: () {
                              _removeFile();
                              formState.didChange(null);
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            if (formState.hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  formState.errorText!,
                  style: AppTextTheme.caption.copyWith(color: AppColors.danger),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.p16),
          ],
        );
      },
    );
  }
}
