import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/stock.dart';

/// Repository interface for stock operations
abstract class StockRepository {
  /// Get all stocks for current branch
  Future<Either<Failure, List<Stock>>> getStocks({
    int? branchId,
    int page = 1,
    int perPage = 20,
  });

  /// Get stock by product ID
  Future<Either<Failure, Stock>> getStockByProduct(int productId, {int? branchId});

  /// Get low stock items
  Future<Either<Failure, List<Stock>>> getLowStocks({int? branchId});

  /// Get stock history for a product
  Future<Either<Failure, List<StockHistory>>> getStockHistory(
    int stockId, {
    int page = 1,
    int perPage = 20,
  });

  /// Update stock quantity
  Future<Either<Failure, Stock>> updateStock(UpdateStockParams params);

  /// Adjust stock (admin only)
  Future<Either<Failure, Stock>> adjustStock(StockAdjustmentParams params);

  /// Search stocks by product name
  Future<Either<Failure, List<Stock>>> searchStocks(
    String query, {
    int? branchId,
  });
}

/// Stock summary for dashboard
class StockSummary {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final int normalStockCount;
  final double totalStockValue;

  const StockSummary({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.normalStockCount,
    required this.totalStockValue,
  });

  factory StockSummary.empty() => const StockSummary(
        totalProducts: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        normalStockCount: 0,
        totalStockValue: 0,
      );
}
