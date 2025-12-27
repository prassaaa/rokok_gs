/// Application-wide constants
class AppConstants {
  AppConstants._();

  // ==================== App Info ====================
  static const String appName = 'Rokok GS';
  static const String appVersion = '1.0.0';

  // ==================== Storage Keys ====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // ==================== Pagination ====================
  static const int defaultPageSize = 15;
  static const int commissionPageSize = 20;

  // ==================== Validation ====================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int phoneMinLength = 10;
  static const int phoneMaxLength = 15;

  // ==================== Date Formats ====================
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // ==================== Animation Durations ====================
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ==================== Debounce ====================
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // ==================== Payment Methods ====================
  static const List<String> paymentMethods = [
    'cash',
    'transfer',
    'credit',
  ];

  // ==================== Commission Status ====================
  static const String commissionPending = 'pending';
  static const String commissionApproved = 'approved';
  static const String commissionPaid = 'paid';

  // ==================== Transaction Status ====================
  static const String transactionPending = 'pending';
  static const String transactionCompleted = 'completed';
  static const String transactionCancelled = 'cancelled';

  // ==================== Roles ====================
  static const String roleAdmin = 'Admin';
  static const String roleManager = 'Manager';
  static const String roleSales = 'Sales';
}
