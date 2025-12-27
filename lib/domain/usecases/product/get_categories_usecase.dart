import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';
import '../usecase.dart';

/// Get Categories UseCase
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
