import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';
import '../usecase.dart';

/// Get Product Detail UseCase
class GetProductDetailUseCase implements UseCase<Product, int> {
  final ProductRepository repository;

  GetProductDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(int id) async {
    return await repository.getProductById(id);
  }
}
