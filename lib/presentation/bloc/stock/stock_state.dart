import 'package:equatable/equatable.dart';

import '../../../domain/entities/stock.dart';

/// Enum for stock status
enum StockStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

/// State class for stock
class StockState extends Equatable {
  final StockStatus status;
  final List<Stock> stocks;
  final List<Stock> lowStocks;
  final Stock? selectedStock;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final String searchQuery;
  final int? branchId;

  const StockState({
    this.status = StockStatus.initial,
    this.stocks = const [],
    this.lowStocks = const [],
    this.selectedStock,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.searchQuery = '',
    this.branchId,
  });

  /// Initial state
  factory StockState.initial() => const StockState();

  /// Check if loading
  bool get isLoading => status == StockStatus.loading;

  /// Check if loading more
  bool get isLoadingMore => status == StockStatus.loadingMore;

  /// Check if error
  bool get hasError => status == StockStatus.error;

  /// Check if loaded
  bool get isLoaded => status == StockStatus.loaded;

  /// Get low stock count
  int get lowStockCount => lowStocks.length;

  /// Get out of stock count
  int get outOfStockCount => stocks.where((s) => s.isEmpty).length;

  StockState copyWith({
    StockStatus? status,
    List<Stock>? stocks,
    List<Stock>? lowStocks,
    Stock? selectedStock,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    String? searchQuery,
    int? branchId,
    bool clearSelectedStock = false,
    bool clearError = false,
  }) {
    return StockState(
      status: status ?? this.status,
      stocks: stocks ?? this.stocks,
      lowStocks: lowStocks ?? this.lowStocks,
      selectedStock: clearSelectedStock ? null : (selectedStock ?? this.selectedStock),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      branchId: branchId ?? this.branchId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stocks,
        lowStocks,
        selectedStock,
        errorMessage,
        hasReachedMax,
        currentPage,
        searchQuery,
        branchId,
      ];
}
