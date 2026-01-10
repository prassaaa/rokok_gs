/// Application configuration for different environments
enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.production;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  /// Base URL for API calls
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        // Gunakan 10.0.2.2 untuk Android Emulator (alias ke localhost host)
        // Atau gunakan IP komputer Anda jika testing di device fisik
        return 'http://10.0.2.2:8000';
      case Environment.staging:
        return 'https://staging-api.rokokgs.com';
      case Environment.production:
        return 'https://gunungsarialami.com';
    }
  }

  /// API Version
  static const String apiVersion = 'v1';

  /// Full API URL
  static String get apiUrl => '$baseUrl/api/$apiVersion';

  /// Connection timeout in milliseconds
  static const int connectionTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Enable logging
  static bool get enableLogging => !isProduction;
}
