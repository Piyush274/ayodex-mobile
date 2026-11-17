class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://ayodex.com/api';

  // App Config & Reference Data
  static const String generalSetting = '/general-setting';
  static const String getCountries = '/get-countries';
  static const String language = '/language';
  static const String policies = '/policies';
  static const String policy = '/policy';
  static const String faq = '/faq';
  static const String currencyRates = '/rate/currencies';
  static const String contact = '/contact';

  // Authentication & Onboarding
  static const String register = '/register';
  static const String login = '/login';
  static const String socialLogin = '/social-login';
  static const String checkToken = '/check-token';
  static const String userDataSubmit = '/user-data-submit';
  static const String userInfo = '/user-info';
  static const String profileSetting = '/profile-setting';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';
  static const String logout = '/logout';

  // Password Recovery & Verification
  static const String passwordEmail = '/password/email';
  static const String passwordVerifyCode = '/password/verify-code';
  static const String passwordReset = '/password/reset';
  static const String authorization = '/authorization';
  static const String resendVerify = '/resend-verify';
  static const String verifyEmail = '/verify-email';
  static const String verifyMobile = '/verify-mobile';
  static const String verifyG2fa = '/verify-g2fa';

  // Security (PIN & 2FA)
  static const String pinStatus = '/user/pin/status';
  static const String pinSet = '/user/pin/set';
  static const String pinChange = '/user/pin/change';
  static const String twofactor = '/twofactor';
  static const String twofactorEnable = '/twofactor/enable';
  static const String twofactorDisable = '/twofactor/disable';

  // KYC
  static const String kycForm = '/kyc-form';
  static const String kycSubmit = '/kyc-submit';

  // Dashboard & Wallet
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';

  // Withdrawals
  static const String withdrawCurrency = '/withdraw/currency';
  static const String withdrawSave = '/withdraw/save';
  static const String withdrawHistory = '/withdraw/history';

  // Exchanges
  static const String currencyList = '/currency/list';
  static const String currencyListSell = '/currency/list/sell';
  static const String currencyListBuy = '/currency/list/buy';
  static const String exchangeCreate = '/exchange/create';
  static const String exchangePreview = '/exchange/preview';
  static const String exchangeConfirm = '/exchange/confirm';
  static const String exchangeManualConfirm = '/exchange/manual/confirm';
  static const String exchangeTrack = '/exchange/track';
  static const String exchangeDetails = '/exchange/details';
  static const String exchangeList = '/exchange/list';

  // Payout Transfers
  static const String transferBanks = '/transfer/banks';
  static const String transferResolveAccount = '/transfer/resolve-account';
  static const String transferQuote = '/transfer/quote';
  static const String transferConfirm = '/transfer/confirm';
  static const String transferHistory = '/transfer/history';
  static const String transferDetail = '/transfer/detail';

  // FCM & Tickets
  static const String addDeviceToken = '/add-device-token';
  static const String pushNotifications = '/push-notifications';
  static const String pushNotificationsRead = '/push-notifications/read';
  static const String ticket = '/ticket';
  static const String ticketCreate = '/ticket/create';
  static const String ticketView = '/ticket/view';
  static const String ticketReply = '/ticket/reply';
  static const String ticketClose = '/ticket/close';
  static const String ticketDownload = '/ticket/download';
  static const String affiliate = '/affiliate';
}
