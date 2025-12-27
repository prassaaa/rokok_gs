import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/stock.dart';
import '../../repositories/stock_repository.dart';

/// Use case for getting low stock items
class GetLowStocksUseCase {
  final StockRepository _repository;

  GetLowStocksUseCase(this._repository);

  Future<Either<Failure, List<Stock>>> call({int? branchId}) {
    return _repository.getLowStocks(branchId: branchId);
  }
}
