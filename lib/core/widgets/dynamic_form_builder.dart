import 'package:flutter/material.dart';
import 'package:ayodex/core/constants/app_colors.dart';
import 'package:ayodex/core/constants/app_dimensions.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/theme/text_theme.dart';
import 'package:ayodex/core/widgets/app_text_field.dart';
import 'file_upload_card.dart';

class DynamicFormBuilder extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final DynamicFormModel schema;
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final ValueChanged<Map<String, UploadedFile>>? onFilesChanged;
  final Map<String, dynamic>? initialValues;

  const DynamicFormBuilder({
    super.key,
    this.formKey,
    required this.schema,
    this.onChanged,
    this.onFilesChanged,
    this.initialValues,
  });

  @override
  State<DynamicFormBuilder> createState() => _DynamicFormBuilderState();
}

class _DynamicFormBuilderState extends State<DynamicFormBuilder> {
  final Map<String, dynamic> _values = {};
  final Map<String, UploadedFile> _files = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _values.addAll(widget.initialValues!);
    }
  }

  void _updateValue(String key, dynamic value) {
    setState(() {
      _values[key] = value;
    });
    widget.onChanged?.call(Map.unmodifiable(_values));
  }

  void _updateFile(String key, UploadedFile? file) {
    setState(() {
      if (file == null) {
        _files.remove(key);
      } else {
        _files[key] = file;
      }
    });
    widget.onFilesChanged?.call(Map.unmodifiable(_files));
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.schema.fields.values.toList();

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields.map((field) => _buildField(field)).toList(),
      ),
    );
  }

  Widget _buildField(DynamicFormFieldModel field) {
    final type = field.type.toLowerCase();

    switch (type) {
      case 'file':
        return _buildFileField(field);
      case 'select':
        return _buildSelectField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'textarea':
        return _buildTextareaField(field);
      case 'number':
        return _buildNumberField(field);
      case 'date':
        return _buildDateField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildFieldInstruction(String? instruction) {
    if (instruction == null || instruction.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        instruction,
        style: AppTextTheme.caption.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildTextField(DynamicFormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldInstruction(field.instruction),
          AppTextField(
            label: field.name,
            hint: field.instruction ?? 'Enter ${field.name}',
            initialValue: _values[field.label]?.toString(),
            onChanged: (val) => _updateValue(field.label, val),
            validator: (val) {
              if (field.isRequired && (val == null || val.trim().isEmpty)) {
                return '${field.name} is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(DynamicFormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldInstruction(field.instruction),
          AppTextField(
            label: field.name,
            hint: field.instruction ?? 'Enter numeric value',
            keyboardType: TextInputType.number,
            initialValue: _values[field.label]?.toString(),
            onChanged: (val) => _updateValue(field.label, val),
            validator: (val) {
              if (field.isRequired && (val == null || val.trim().isEmpty)) {
                return '${field.name} is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextareaField(DynamicFormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldInstruction(field.instruction),
          AppTextField(
            label: field.name,
            hint: field.instruction ?? 'Enter description...',
            maxLines: 4,
            initialValue: _values[field.label]?.toString(),
            onChanged: (val) => _updateValue(field.label, val),
            validator: (val) {
              if (field.isRequired && (val == null || val.trim().isEmpty)) {
                return '${field.name} is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileField(DynamicFormFieldModel field) {
    return FileUploadCard(
      label: field.name,
      instruction: field.instruction,
      allowedExtensions: field.allowedExtensions,
      isRequired: field.isRequired,
      initialFile: _files[field.label],
      onFileSelected: (file) => _updateFile(field.label, file),
    );
  }

  Widget _buildSelectField(DynamicFormFieldModel field) {
    final currentVal = _values[field.label]?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.name,
                style: AppTextTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
              if (field.isRequired)
                const Text(' *', style: TextStyle(color: AppColors.danger)),
            ],
          ),
          _buildFieldInstruction(field.instruction),
          const SizedBox(height: AppDimensions.p8),
          DropdownButtonFormField<String>(
            value: field.options.contains(currentVal) ? currentVal : null,
            decoration: InputDecoration(
              hintText: 'Select ${field.name}',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: field.options.map((opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(opt, style: AppTextTheme.bodyMedium),
              );
            }).toList(),
            onChanged: (val) => _updateValue(field.label, val),
            validator: (val) {
              if (field.isRequired && (val == null || val.isEmpty)) {
                return '${field.name} is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(DynamicFormFieldModel field) {
    final selectedVal = _values[field.label]?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: FormField<String>(
        initialValue: selectedVal,
        validator: (val) {
          if (field.isRequired && (selectedVal == null || selectedVal.isEmpty)) {
            return '${field.name} is required';
          }
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.name,
                style: AppTextTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
              _buildFieldInstruction(field.instruction),
              const SizedBox(height: AppDimensions.p8),
              ...field.options.map((opt) {
                return RadioListTile<String>(
                  title: Text(opt, style: AppTextTheme.bodyMedium),
                  value: opt,
                  groupValue: selectedVal,
                  activeColor: AppColors.base,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    _updateValue(field.label, val);
                    state.didChange(val);
                  },
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText!,
                    style: AppTextTheme.caption.copyWith(color: AppColors.danger),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckboxField(DynamicFormFieldModel field) {
    final selectedList = List<String>.from(_values[field.label] as List? ?? []);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: FormField<List<String>>(
        initialValue: selectedList,
        validator: (val) {
          if (field.isRequired && selectedList.isEmpty) {
            return 'Please select at least one option for ${field.name}';
          }
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.name,
                style: AppTextTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
              _buildFieldInstruction(field.instruction),
              const SizedBox(height: AppDimensions.p8),
              ...field.options.map((opt) {
                final isChecked = selectedList.contains(opt);
                return CheckboxListTile(
                  title: Text(opt, style: AppTextTheme.bodyMedium),
                  value: isChecked,
                  activeColor: AppColors.base,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (checked) {
                    if (checked == true) {
                      selectedList.add(opt);
                    } else {
                      selectedList.remove(opt);
                    }
                    _updateValue(field.label, selectedList);
                    state.didChange(selectedList);
                  },
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.errorText!,
                    style: AppTextTheme.caption.copyWith(color: AppColors.danger),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateField(DynamicFormFieldModel field) {
    final selectedDate = _values[field.label]?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.name,
            style: AppTextTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
          _buildFieldInstruction(field.instruction),
          const SizedBox(height: AppDimensions.p8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                _updateValue(field.label, formatted);
              }
            },
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              height: AppDimensions.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                color: AppColors.surface,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate ?? 'Select date',
                      style: AppTextTheme.bodyLarge.copyWith(
                        color: selectedDate != null ? AppColors.heading : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
