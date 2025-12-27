import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';
import '../usecase.dart';

/// Get Products UseCase
class GetProductsUseCase
    implements UseCase<PaginatedResponse<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<Product>>> call(
    GetProductsParams params,
  ) async {
    return await repository.getProducts(
      page: params.page,
      perPage: params.perPage,
      search: params.search,
      categoryId: params.categoryId,
    );
  }
}

/// Get products parameters
class GetProductsParams extends Equatable {
  final int page;
  final int perPage;
  final String? search;
  final int? categoryId;

  const GetProductsParams({
    this.page = 1,
    this.perPage = 15,
    this.search,
    this.categoryId,
  });

  @override
  List<Object?> get props => [page, perPage, search, categoryId];
}
