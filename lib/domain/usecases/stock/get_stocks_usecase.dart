import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/stock.dart';
import '../../repositories/stock_repository.dart';

/// Use case for getting all stocks
class GetStocksUseCase {
  final StockRepository _repository;

  GetStocksUseCase(this._repository);

  Future<Either<Failure, List<Stock>>> call({
    int? branchId,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.getStocks(
      branchId: branchId,
      page: page,
      perPage: perPage,
    );
  }
}
