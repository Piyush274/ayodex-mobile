import 'package:decimal/decimal.dart';

class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final String dialCode;
  final String mobile;
  final String? countryCode;
  final String? countryName;
  final String? city;
  final String? state;
  final String? zip;
  final String? address;
  final Decimal balance;
  final int status;
  final int kv; // KYC: 0=unverified, 1=verified, 2=pending
  final int ev; // Email: 1=verified, 0=unverified
  final int sv; // SMS: 1=verified, 0=unverified
  final int ts; // 2FA: 1=enabled, 0=disabled
  final int profileComplete; // 1=yes, 0=no

  const UserModel({
    required this.id,
    this.firstname = '',
    this.lastname = '',
    required this.username,
    required this.email,
    this.dialCode = '',
    this.mobile = '',
    this.countryCode,
    this.countryName,
    this.city,
    this.state,
    this.zip,
    this.address,
    required this.balance,
    this.status = 1,
    this.kv = 0,
    this.ev = 1,
    this.sv = 1,
    this.ts = 0,
    this.profileComplete = 0,
  });

  String get fullName => '$firstname $lastname'.trim();
  bool get isKycVerified => kv == 1;
  bool get isKycPending => kv == 2;
  bool get isKycUnverified => kv == 0;
  bool get isProfileComplete => profileComplete == 1;
  bool get isActive => status == 1;
  bool get is2faEnabled => ts == 1;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dialCode: json['dial_code']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      countryCode: json['country_code']?.toString(),
      countryName: json['country_name']?.toString() ?? json['country']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zip: json['zip']?.toString(),
      address: json['address']?.toString(),
      balance: Decimal.tryParse(json['balance']?.toString() ?? '0') ?? Decimal.zero,
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      kv: json['kv'] is int ? json['kv'] as int : int.tryParse(json['kv']?.toString() ?? '0') ?? 0,
      ev: json['ev'] is int ? json['ev'] as int : int.tryParse(json['ev']?.toString() ?? '1') ?? 1,
      sv: json['sv'] is int ? json['sv'] as int : int.tryParse(json['sv']?.toString() ?? '1') ?? 1,
      ts: json['ts'] is int ? json['ts'] as int : int.tryParse(json['ts']?.toString() ?? '0') ?? 0,
      profileComplete: json['profile_complete'] is int
          ? json['profile_complete'] as int
          : int.tryParse(json['profile_complete']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'username': username,
    'email': email,
    'dial_code': dialCode,
    'mobile': mobile,
    'country_code': countryCode,
    'country_name': countryName,
    'city': city,
    'state': state,
    'zip': zip,
    'address': address,
    'balance': balance.toString(),
    'status': status,
    'kv': kv,
    'ev': ev,
    'sv': sv,
    'ts': ts,
    'profile_complete': profileComplete,
  };
}
