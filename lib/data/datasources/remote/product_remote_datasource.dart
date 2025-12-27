import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/pagination_model.dart';
import '../../models/product_model.dart';

/// Remote data source for products
abstract class ProductRemoteDataSource {
  /// Get paginated products
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
  });

  /// Get product by ID
  Future<ProductModel> getProductById(int id);

  /// Get products by category
  Future<PaginatedResponse<ProductModel>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  });

  /// Get all categories
  Future<List<CategoryModel>> getCategories();

  /// Search products
  Future<List<ProductModel>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
      };

      final response = await apiClient.dio.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => ProductModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get products',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.productDetail(id),
      );

      final data = response.data;
      if (data['success'] == true) {
        return ProductModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get product',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponse<ProductModel>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
      };

      final response = await apiClient.dio.get(
        ApiConstants.productsByCategory(categoryId),
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => ProductModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get products by category',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.categories);

      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> items = data['data'] ?? [];
        return items
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get categories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.products,
        queryParameters: {'search': query, 'per_page': 20},
      );

      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> items = data['data'] ?? [];
        return items
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to search products',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final data = e.response?.data;
        String message = 'Something went wrong';

        if (data is Map) {
          message = data['message'] ?? message;
        }

        if (statusCode == 401) {
          return AuthException(message: message, statusCode: statusCode);
        }

        return ServerException.fromStatusCode(statusCode, message);
      default:
        return ServerException(
          message: e.message ?? 'Something went wrong',
        );
    }
  }
}
