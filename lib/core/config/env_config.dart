enum Environment { production, staging, local }

class EnvConfig {
  EnvConfig._();

  static Environment currentEnvironment = Environment.production;

  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.local:
        return 'http://10.0.2.2:8000/api'; // Android emulator localhost
      case Environment.staging:
        return 'https://ayodex.com/api';
      case Environment.production:
        return 'https://ayodex.com/api';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const bool enableLogging = true;
}
