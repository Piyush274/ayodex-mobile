class TwoFactorModel {
  final String secret;
  final String qrCodeUrl;
  final bool isEnabled;

  const TwoFactorModel({
    required this.secret,
    required this.qrCodeUrl,
    this.isEnabled = false,
  });

  factory TwoFactorModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorModel(
      secret: json['secret']?.toString() ?? json['key']?.toString() ?? '',
      qrCodeUrl: json['qr_code_url']?.toString() ?? json['qrCodeUrl']?.toString() ?? '',
      isEnabled: json['is_enabled'] == true || json['is_enabled'] == 1 || json['ts'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'secret': secret,
    'qr_code_url': qrCodeUrl,
    'is_enabled': isEnabled,
  };
}
