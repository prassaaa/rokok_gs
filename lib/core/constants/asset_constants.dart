/// Asset path constants
class AssetConstants {
  AssetConstants._();

  // ==================== Base Paths ====================
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _lottiePath = 'assets/lottie';

  // ==================== Images ====================
  static const String logo = '$_imagesPath/logo.png';
  static const String logoWhite = '$_imagesPath/logo_white.png';
  static const String placeholder = '$_imagesPath/placeholder.png';
  static const String emptyState = '$_imagesPath/empty_state.png';
  static const String errorState = '$_imagesPath/error_state.png';
  static const String noConnection = '$_imagesPath/no_connection.png';

  // ==================== Icons ====================
  static const String icHome = '$_iconsPath/ic_home.svg';
  static const String icProduct = '$_iconsPath/ic_product.svg';
  static const String icTransaction = '$_iconsPath/ic_transaction.svg';
  static const String icStock = '$_iconsPath/ic_stock.svg';
  static const String icCommission = '$_iconsPath/ic_commission.svg';
  static const String icProfile = '$_iconsPath/ic_profile.svg';

  // ==================== Lottie ====================
  static const String loadingAnimation = '$_lottiePath/loading.json';
  static const String successAnimation = '$_lottiePath/success.json';
  static const String errorAnimation = '$_lottiePath/error.json';
}
