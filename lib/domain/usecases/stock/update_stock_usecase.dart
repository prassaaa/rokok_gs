import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/stock.dart';
import '../../repositories/stock_repository.dart';

/// Use case for updating stock quantity
class UpdateStockUseCase {
  final StockRepository _repository;

  UpdateStockUseCase(this._repository);

  Future<Either<Failure, Stock>> call(UpdateStockParams params) {
    return _repository.updateStock(params);
  }
}
