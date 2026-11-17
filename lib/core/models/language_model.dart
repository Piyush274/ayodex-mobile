class LanguageModel {
  final int id;
  final String name;
  final String code;
  final bool isDefault;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.code,
    this.isDefault = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? 'en',
      isDefault: json['is_default'] == 1 || json['is_default'] == '1' || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'is_default': isDefault ? 1 : 0,
  };
}
