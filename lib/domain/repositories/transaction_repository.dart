import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/pagination_model.dart';
import '../entities/transaction.dart';

/// Abstract repository for transactions
abstract class TransactionRepository {
  /// Get paginated list of transactions
  Future<Either<Failure, PaginatedResponse<Transaction>>> getTransactions({
    int page = 1,
    int perPage = 15,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  });

  /// Get transaction by ID
  Future<Either<Failure, Transaction>> getTransactionById(int id);

  /// Get transactions by sales ID
  Future<Either<Failure, PaginatedResponse<Transaction>>> getTransactionsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  });

  /// Create new transaction
  Future<Either<Failure, Transaction>> createTransaction(
    CreateTransactionParams params,
  );

  /// Get today's transactions summary
  Future<Either<Failure, TransactionSummary>> getTodaySummary();
}

/// Transaction summary
class TransactionSummary {
  final int totalTransactions;
  final double totalSales;
  final int totalItems;
  final double averageTransaction;

  const TransactionSummary({
    this.totalTransactions = 0,
    this.totalSales = 0,
    this.totalItems = 0,
    this.averageTransaction = 0,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalTransactions: json['total_transactions'] ?? 0,
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      totalItems: json['total_items'] ?? 0,
      averageTransaction: (json['average_transaction'] as num?)?.toDouble() ?? 0,
    );
  }

  String get formattedTotalSales => 'Rp ${totalSales.toStringAsFixed(0)}';
  String get formattedAverage => 'Rp ${averageTransaction.toStringAsFixed(0)}';
}
