import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/stock/stock_usecases.dart';
import '../../../domain/repositories/stock_repository.dart';
import 'stock_event.dart';
import 'stock_state.dart';

/// BLoC for managing stock state (READ-ONLY - API only supports GET)
class StockBloc extends Bloc<StockEvent, StockState> {
  final GetStocksUseCase _getStocksUseCase;
  final GetLowStocksUseCase _getLowStocksUseCase;
  final GetStockByProductUseCase _getStockByProductUseCase;
  final StockRepository _repository;

  static const int _perPage = 20;

  StockBloc({
    required GetStocksUseCase getStocksUseCase,
    required GetLowStocksUseCase getLowStocksUseCase,
    required GetStockByProductUseCase getStockByProductUseCase,
    required StockRepository repository,
  })  : _getStocksUseCase = getStocksUseCase,
        _getLowStocksUseCase = getLowStocksUseCase,
        _getStockByProductUseCase = getStockByProductUseCase,
        _repository = repository,
        super(StockState.initial()) {
    on<StocksLoadRequested>(_onStocksLoadRequested);
    on<LowStocksLoadRequested>(_onLowStocksLoadRequested);
    on<StocksLoadMoreRequested>(_onStocksLoadMoreRequested);
    on<StocksSearchChanged>(_onStocksSearchChanged);
    on<StockByProductRequested>(_onStockByProductRequested);
    on<StockErrorCleared>(_onStockErrorCleared);
  }

  Future<void> _onStocksLoadRequested(
    StocksLoadRequested event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(
      status: StockStatus.loading,
      branchId: event.branchId,
      clearError: true,
    ));

    final result = await _getStocksUseCase(
      branchId: event.branchId,
      page: 1,
      perPage: _perPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: failure.message,
      )),
      (stocks) => emit(state.copyWith(
        status: StockStatus.loaded,
        stocks: stocks,
        hasReachedMax: stocks.length < _perPage,
        currentPage: 1,
        searchQuery: '',
      )),
    );
  }

  Future<void> _onLowStocksLoadRequested(
    LowStocksLoadRequested event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading, clearError: true));

    final result = await _getLowStocksUseCase(branchId: event.branchId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: failure.message,
      )),
      (lowStocks) => emit(state.copyWith(
        status: StockStatus.loaded,
        lowStocks: lowStocks,
      )),
    );
  }

  Future<void> _onStocksLoadMoreRequested(
    StocksLoadMoreRequested event,
    Emitter<StockState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: StockStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    final result = state.searchQuery.isNotEmpty
        ? await _repository.searchStocks(
            state.searchQuery,
            branchId: state.branchId,
          )
        : await _getStocksUseCase(
            branchId: state.branchId,
            page: nextPage,
            perPage: _perPage,
          );

    result.fold(
      (failure) => emit(state.copyWith(
        status: StockStatus.loaded,
        errorMessage: failure.message,
      )),
      (newStocks) => emit(state.copyWith(
        status: StockStatus.loaded,
        stocks: [...state.stocks, ...newStocks],
        hasReachedMax: newStocks.length < _perPage,
        currentPage: nextPage,
      )),
    );
  }

  Future<void> _onStocksSearchChanged(
    StocksSearchChanged event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(
      status: StockStatus.loading,
      searchQuery: event.query,
      clearError: true,
    ));

    if (event.query.isEmpty) {
      add(StocksLoadRequested(branchId: state.branchId));
      return;
    }

    final result = await _repository.searchStocks(
      event.query,
      branchId: state.branchId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: failure.message,
      )),
      (stocks) => emit(state.copyWith(
        status: StockStatus.loaded,
        stocks: stocks,
        hasReachedMax: true,
        currentPage: 1,
      )),
    );
  }
  
  Future<void> _onStockByProductRequested(
    StockByProductRequested event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading, clearError: true));

    final result = await _getStockByProductUseCase(
      event.productId,
      branchId: event.branchId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: failure.message,
      )),
      (stock) => emit(state.copyWith(
        status: StockStatus.loaded,
        selectedStock: stock,
      )),
    );
  }

  void _onStockErrorCleared(
    StockErrorCleared event,
    Emitter<StockState> emit,
  ) {
    emit(state.copyWith(clearError: true, status: StockStatus.loaded));
  }
}
