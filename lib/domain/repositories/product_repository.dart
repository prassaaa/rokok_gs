import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/pagination_model.dart';
import '../entities/product.dart';

/// Abstract repository for products
abstract class ProductRepository {
  /// Get paginated list of products
  Future<Either<Failure, PaginatedResponse<Product>>> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
  });

  /// Get product by ID
  Future<Either<Failure, Product>> getProductById(int id);

  /// Get products by category
  Future<Either<Failure, PaginatedResponse<Product>>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  });

  /// Get all categories
  Future<Either<Failure, List<Category>>> getCategories();

  /// Search products
  Future<Either<Failure, List<Product>>> searchProducts(String query);
}
