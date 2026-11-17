class PinStatusModel {
  final bool hasPin;
  final bool isLocked;
  final int lockoutRemainingMinutes;
  final bool requires2fa;

  const PinStatusModel({
    this.hasPin = false,
    this.isLocked = false,
    this.lockoutRemainingMinutes = 0,
    this.requires2fa = false,
  });

  factory PinStatusModel.fromJson(Map<String, dynamic> json) {
    return PinStatusModel(
      hasPin: json['has_pin'] == 1 || json['has_pin'] == '1' || json['has_pin'] == true,
      isLocked: json['is_locked'] == 1 || json['is_locked'] == '1' || json['is_locked'] == true,
      lockoutRemainingMinutes: int.tryParse(json['lockout_remaining_minutes']?.toString() ?? '0') ?? 0,
      requires2fa: json['requires_2fa'] == 1 || json['requires_2fa'] == '1' || json['requires_2fa'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'has_pin': hasPin,
    'is_locked': isLocked,
    'lockout_remaining_minutes': lockoutRemainingMinutes,
    'requires_2fa': requires2fa,
  };
}
