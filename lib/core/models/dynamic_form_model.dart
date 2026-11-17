class DynamicFormFieldModel {
  final String name;
  final String label;
  final String type;
  final bool isRequired;
  final String? instruction;
  final List<String> allowedExtensions;
  final List<String> options;
  final int width;

  const DynamicFormFieldModel({
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.instruction,
    this.allowedExtensions = const [],
    this.options = const [],
    this.width = 12,
  });

  factory DynamicFormFieldModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedExtensions = [];
    final extRaw = json['extensions']?.toString();
    if (extRaw != null && extRaw.isNotEmpty && extRaw != 'null') {
      parsedExtensions = extRaw.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    }

    List<String> parsedOptions = [];
    final optRaw = json['options'];
    if (optRaw is List) {
      parsedOptions = optRaw.map((e) => e.toString().trim()).toList();
    } else if (optRaw is String && optRaw.isNotEmpty) {
      parsedOptions = optRaw.split(',').map((e) => e.trim()).toList();
    }

    return DynamicFormFieldModel(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'text',
      isRequired: json['is_required']?.toString().toLowerCase() == 'required',
      instruction: json['instruction']?.toString(),
      allowedExtensions: parsedExtensions,
      options: parsedOptions,
      width: int.tryParse(json['width']?.toString() ?? '12') ?? 12,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'type': type,
    'is_required': isRequired ? 'required' : 'optional',
    'instruction': instruction,
    'extensions': allowedExtensions.join(','),
    'options': options,
    'width': width.toString(),
  };
}

class DynamicFormModel {
  final Map<String, DynamicFormFieldModel> fields;

  const DynamicFormModel({
    this.fields = const {},
  });

  factory DynamicFormModel.fromJson(dynamic json) {
    if (json == null) {
      return const DynamicFormModel();
    }

    final Map<String, DynamicFormFieldModel> parsedFields = {};

    if (json is Map<String, dynamic>) {
      // Check if wrapped in form_data
      final formMap = json.containsKey('form_data') && json['form_data'] is Map<String, dynamic>
          ? json['form_data'] as Map<String, dynamic>
          : json;

      formMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedFields[key] = DynamicFormFieldModel.fromJson(value);
        }
      });
    } else if (json is List) {
      for (final item in json) {
        if (item is Map<String, dynamic>) {
          final label = item['label']?.toString() ?? item['name']?.toString() ?? '';
          if (label.isNotEmpty) {
            parsedFields[label] = DynamicFormFieldModel.fromJson(item);
          }
        }
      }
    }

    return DynamicFormModel(fields: parsedFields);
  }

  Map<String, dynamic> toJson() => fields.map((key, value) => MapEntry(key, value.toJson()));
}
