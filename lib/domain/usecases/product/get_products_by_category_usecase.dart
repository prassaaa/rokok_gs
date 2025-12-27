import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';
import '../usecase.dart';

/// Get Products By Category UseCase
class GetProductsByCategoryUseCase
    implements UseCase<PaginatedResponse<Product>, GetProductsByCategoryParams> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<Product>>> call(
    GetProductsByCategoryParams params,
  ) async {
    return await repository.getProductsByCategory(
      categoryId: params.categoryId,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

/// Get products by category parameters
class GetProductsByCategoryParams extends Equatable {
  final int categoryId;
  final int page;
  final int perPage;

  const GetProductsByCategoryParams({
    required this.categoryId,
    this.page = 1,
    this.perPage = 15,
  });

  @override
  List<Object?> get props => [categoryId, page, perPage];
}
