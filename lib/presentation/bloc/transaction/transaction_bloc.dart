import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/transaction/get_sales_transactions.dart';
import '../../../domain/usecases/transaction/get_today_summary.dart';
import '../../../domain/usecases/transaction/get_transaction_detail.dart';
import '../../../domain/usecases/transaction/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC for managing transaction list
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final GetTransactionDetail getTransactionDetail;
  final GetSalesTransactions getSalesTransactions;
  final GetTodaySummary getTodaySummary;

  TransactionBloc({
    required this.getTransactions,
    required this.getTransactionDetail,
    required this.getSalesTransactions,
    required this.getTodaySummary,
  }) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<LoadTransactionDetail>(_onLoadTransactionDetail);
    on<LoadSalesTransactions>(_onLoadSalesTransactions);
    on<LoadMoreSalesTransactions>(_onLoadMoreSalesTransactions);
    on<LoadTodaySummary>(_onLoadTodaySummary);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<ClearFilters>(_onClearFilters);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (event.refresh && state is TransactionLoaded) {
      // Keep current data while refreshing
      final currentState = state as TransactionLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const TransactionLoading());
    }

    final result = await getTransactions(
      page: 1,
      perPage: AppConstants.defaultPageSize,
      startDate: event.startDate,
      endDate: event.endDate,
      status: event.status,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(TransactionLoaded(
        transactions: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        startDate: event.startDate,
        endDate: event.endDate,
        statusFilter: event.status,
      )),
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getTransactions(
      page: currentState.currentPage + 1,
      perPage: AppConstants.defaultPageSize,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
      status: currentState.statusFilter,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) => emit(currentState.copyWith(
        transactions: [...currentState.transactions, ...response.data],
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadTransactionDetail(
    LoadTransactionDetail event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionDetailLoading());

    final result = await getTransactionDetail(event.transactionId);

    result.fold(
      (failure) => emit(TransactionDetailError(failure.message)),
      (transaction) => emit(TransactionDetailLoaded(transaction)),
    );
  }

  Future<void> _onLoadSalesTransactions(
    LoadSalesTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (event.refresh && state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const TransactionLoading());
    }

    final result = await getSalesTransactions(
      salesId: event.salesId,
      page: 1,
      perPage: AppConstants.defaultPageSize,
    );

    result.fold(
      (failure) => emit(TransactionError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(TransactionLoaded(
        transactions: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      )),
    );
  }

  Future<void> _onLoadMoreSalesTransactions(
    LoadMoreSalesTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getSalesTransactions(
      salesId: event.salesId,
      page: currentState.currentPage + 1,
      perPage: AppConstants.defaultPageSize,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) => emit(currentState.copyWith(
        transactions: [...currentState.transactions, ...response.data],
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadTodaySummary(
    LoadTodaySummary event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    final result = await getTodaySummary();

    result.fold(
      (failure) {}, // Silent fail for summary
      (summary) => emit(currentState.copyWith(summary: summary)),
    );
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions(
      status: event.status,
      startDate: state is TransactionLoaded
          ? (state as TransactionLoaded).startDate
          : null,
      endDate: state is TransactionLoaded
          ? (state as TransactionLoaded).endDate
          : null,
    ));
  }

  Future<void> _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions(
      startDate: event.startDate,
      endDate: event.endDate,
      status: state is TransactionLoaded
          ? (state as TransactionLoaded).statusFilter
          : null,
    ));
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<TransactionState> emit,
  ) async {
    add(const LoadTransactions());
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      add(LoadTransactions(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        status: currentState.statusFilter,
        refresh: true,
      ));
    } else {
      add(const LoadTransactions(refresh: true));
    }
  }
}
