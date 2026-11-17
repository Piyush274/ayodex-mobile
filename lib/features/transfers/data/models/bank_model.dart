class BankModel {
  final String id;
  final String code;
  final String name;
  final String type; // 'bank' or 'opay_wallet'
  final String country;
  final String currency;
  final bool active;

  const BankModel({
    required this.id,
    required this.code,
    required this.name,
    this.type = 'bank',
    this.country = 'NG',
    this.currency = 'NGN',
    this.active = true,
  });

  bool get isOpay => type == 'opay_wallet' || code.toLowerCase() == 'opay';

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id']?.toString() ?? json['code']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'bank',
      country: json['country']?.toString() ?? 'NG',
      currency: json['currency']?.toString() ?? 'NGN',
      active: json['active'] == 1 || json['active'] == '1' || json['active'] == true || json['active'] == null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'type': type,
    'country': country,
    'currency': currency,
    'active': active ? 1 : 0,
  };
}
