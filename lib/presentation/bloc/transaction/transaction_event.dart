import 'package:equatable/equatable.dart';

import '../../../domain/entities/transaction.dart';

/// Transaction list events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load transactions
class LoadTransactions extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionStatus? status;
  final bool refresh;

  const LoadTransactions({
    this.startDate,
    this.endDate,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [startDate, endDate, status, refresh];
}

/// Load more transactions (pagination)
class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

/// Load transaction detail
class LoadTransactionDetail extends TransactionEvent {
  final int transactionId;

  const LoadTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Load transactions by sales ID
class LoadSalesTransactions extends TransactionEvent {
  final int salesId;
  final bool refresh;

  const LoadSalesTransactions({
    required this.salesId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [salesId, refresh];
}

/// Load more sales transactions
class LoadMoreSalesTransactions extends TransactionEvent {
  final int salesId;

  const LoadMoreSalesTransactions({required this.salesId});

  @override
  List<Object?> get props => [salesId];
}

/// Load today's summary
class LoadTodaySummary extends TransactionEvent {
  const LoadTodaySummary();
}

/// Filter transactions by status
class FilterByStatus extends TransactionEvent {
  final TransactionStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter transactions by date range
class FilterByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Clear filters
class ClearFilters extends TransactionEvent {
  const ClearFilters();
}

/// Refresh transactions
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}
