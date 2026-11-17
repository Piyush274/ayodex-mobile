class GeneralSettingModel {
  final String siteName;
  final String curText;
  final String curSym;
  final String baseColor;
  final String activeTemplate;
  final bool transferEnabled;
  final bool withdrawEnabled;
  final bool registrationEnabled;
  final bool agreePolicyRequired;
  final bool securePassword;
  final int transferQuoteValiditySeconds;

  const GeneralSettingModel({
    this.siteName = 'AYODEX',
    this.curText = 'USD',
    this.curSym = '\$',
    this.baseColor = 'FF6033',
    this.activeTemplate = 'orange_oasis',
    this.transferEnabled = true,
    this.withdrawEnabled = true,
    this.registrationEnabled = true,
    this.agreePolicyRequired = true,
    this.securePassword = false,
    this.transferQuoteValiditySeconds = 120,
  });

  factory GeneralSettingModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingModel(
      siteName: json['site_name']?.toString() ?? 'AYODEX',
      curText: json['cur_text']?.toString() ?? 'USD',
      curSym: json['cur_sym']?.toString() ?? '\$',
      baseColor: json['base_color']?.toString() ?? 'FF6033',
      activeTemplate: json['active_template']?.toString() ?? 'orange_oasis',
      transferEnabled: json['transfer_enabled'] == 1 || json['transfer_enabled'] == '1' || json['transfer_enabled'] == true,
      withdrawEnabled: json['withdraw_enabled'] == 1 || json['withdraw_enabled'] == '1' || json['withdraw_enabled'] == true,
      registrationEnabled: json['registration'] == 1 || json['registration'] == '1' || json['registration'] == true,
      agreePolicyRequired: json['agree'] == 1 || json['agree'] == '1' || json['agree'] == true,
      securePassword: json['secure_password'] == 1 || json['secure_password'] == '1' || json['secure_password'] == true,
      transferQuoteValiditySeconds: int.tryParse(json['transfer_quote_validity_seconds']?.toString() ?? '120') ?? 120,
    );
  }

  Map<String, dynamic> toJson() => {
    'site_name': siteName,
    'cur_text': curText,
    'cur_sym': curSym,
    'base_color': baseColor,
    'active_template': activeTemplate,
    'transfer_enabled': transferEnabled ? 1 : 0,
    'withdraw_enabled': withdrawEnabled ? 1 : 0,
    'registration': registrationEnabled ? 1 : 0,
    'agree': agreePolicyRequired ? 1 : 0,
    'secure_password': securePassword ? 1 : 0,
    'transfer_quote_validity_seconds': transferQuoteValiditySeconds,
  };
}
