import 'package:equatable/equatable.dart';

/// Base class for stock events
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load stocks
class StocksLoadRequested extends StockEvent {
  final int? branchId;
  final bool refresh;

  const StocksLoadRequested({
    this.branchId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [branchId, refresh];
}

/// Event to load low stocks
class LowStocksLoadRequested extends StockEvent {
  final int? branchId;

  const LowStocksLoadRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

/// Event to load more stocks (pagination)
class StocksLoadMoreRequested extends StockEvent {
  const StocksLoadMoreRequested();
}

/// Event to search stocks
class StocksSearchChanged extends StockEvent {
  final String query;

  const StocksSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to get stock by product
class StockByProductRequested extends StockEvent {
  final int productId;
  final int? branchId;

  const StockByProductRequested({
    required this.productId,
    this.branchId,
  });

  @override
  List<Object?> get props => [productId, branchId];
}

/// Event to clear stock error
class StockErrorCleared extends StockEvent {
  const StockErrorCleared();
}
