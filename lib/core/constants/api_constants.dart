/// API Endpoints Constants
class ApiConstants {
  ApiConstants._();

  // ==================== Authentication ====================
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';

  // ==================== Products ====================
  static const String products = '/products';
  static const String categories = '/categories';
  static String productDetail(int id) => '/products/$id';
  static String productsByCategory(int categoryId) =>
      '/products/category/$categoryId';

  // ==================== Stock ====================
  static const String stocks = '/stocks';
  static String stockByProduct(int productId) => '/stocks/product/$productId';
  static const String lowStock = '/stocks/low-stock';

  // ==================== Transactions ====================
  static const String transactions = '/transactions';
  static String transactionDetail(int id) => '/transactions/$id';
  static String transactionsBySales(int salesId) =>
      '/transactions/sales/$salesId';

  // ==================== Commissions ====================
  static const String commissions = '/commissions';
  static const String commissionSummary = '/commissions/summary';

  // ==================== Areas ====================
  static const String areas = '/areas';
  static String areaDetail(int id) => '/areas/$id';

  // ==================== Visits ====================
  static const String visits = '/visits';
  static String visitDetail(int id) => '/visits/$id';
  static String visitsBySales(int salesId) => '/visits/sales/$salesId';
  static const String visitStatistics = '/visits/statistics';
}
