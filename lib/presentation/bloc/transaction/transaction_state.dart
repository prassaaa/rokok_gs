import 'package:equatable/equatable.dart';

import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';

/// Transaction list states
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// Loading state
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Loaded state with transactions
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionStatus? statusFilter;
  final TransactionSummary? summary;
  final bool isLoadingMore;

  const TransactionLoaded({
    required this.transactions,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.startDate,
    this.endDate,
    this.statusFilter,
    this.summary,
    this.isLoadingMore = false,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? statusFilter,
    TransactionSummary? summary,
    bool? isLoadingMore,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearStatusFilter = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      statusFilter: clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      summary: summary ?? this.summary,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  bool get hasFilters =>
      startDate != null || endDate != null || statusFilter != null;

  @override
  List<Object?> get props => [
        transactions,
        hasReachedMax,
        currentPage,
        totalPages,
        startDate,
        endDate,
        statusFilter,
        summary,
        isLoadingMore,
      ];
}

/// Error state
class TransactionError extends TransactionState {
  final String message;
  final bool isNetworkError;

  const TransactionError({
    required this.message,
    this.isNetworkError = false,
  });

  @override
  List<Object?> get props => [message, isNetworkError];
}

/// Transaction detail loading
class TransactionDetailLoading extends TransactionState {
  const TransactionDetailLoading();
}

/// Transaction detail loaded
class TransactionDetailLoaded extends TransactionState {
  final Transaction transaction;

  const TransactionDetailLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Transaction detail error
class TransactionDetailError extends TransactionState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
