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

  Map<String, dynamic> toJson() => {
    'country': country,
    'dial_code': dialCode,
    'country_code': countryCode,
  };
}
