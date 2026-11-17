class CountryModel {
  final String country;
  final String dialCode;
  final String countryCode;

  const CountryModel({
    required this.country,
    required this.dialCode,
    required this.countryCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      country: json['country']?.toString() ?? '',
      dialCode: json['dial_code']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
    );
  }

  String get flagEmoji {
    if (countryCode.length != 2) return '🌐';
    final int firstLetter = countryCode.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  Map<String, dynamic> toJson() => {
    'country': country,
    'dial_code': dialCode,
    'country_code': countryCode,
  };
}
