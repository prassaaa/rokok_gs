import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/stock.dart';
import '../../repositories/stock_repository.dart';

/// Use case for getting stock by product ID
class GetStockByProductUseCase {
  final StockRepository _repository;

  GetStockByProductUseCase(this._repository);

  Future<Either<Failure, Stock>> call(int productId, {int? branchId}) {
    return _repository.getStockByProduct(productId, branchId: branchId);
  }
}
