import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/stock_model.dart';
import '../../../domain/entities/stock.dart';

/// Remote data source for stock operations
abstract class StockRemoteDataSource {
  /// Get all stocks
  Future<List<StockModel>> getStocks({
    int? branchId,
    int page = 1,
    int perPage = 20,
  });

  /// Get stock by product ID
  Future<StockModel> getStockByProduct(int productId, {int? branchId});

  /// Get low stock items
  Future<List<StockModel>> getLowStocks({int? branchId});

  /// Get stock history
  Future<List<StockHistoryModel>> getStockHistory(
    int stockId, {
    int page = 1,
    int perPage = 20,
  });

  /// Update stock
  Future<StockModel> updateStock(UpdateStockParams params);

  /// Adjust stock
  Future<StockModel> adjustStock(StockAdjustmentParams params);

  /// Search stocks
  Future<List<StockModel>> searchStocks(String query, {int? branchId});
}

/// Implementation of StockRemoteDataSource
class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final ApiClient _apiClient;

  StockRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<StockModel>> getStocks({
    int? branchId,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (branchId != null) {
      queryParams['branch_id'] = branchId;
    }

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.stocks,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data
          .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StockModel> getStockByProduct(int productId, {int? branchId}) async {
    final queryParams = <String, dynamic>{};
    if (branchId != null) {
      queryParams['branch_id'] = branchId;
    }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.stocks}/product/$productId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data['data'] ?? response.data;
      return StockModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StockModel>> getLowStocks({int? branchId}) async {
    final queryParams = <String, dynamic>{};
    if (branchId != null) {
      queryParams['branch_id'] = branchId;
    }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.stocks}/low-stock',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data
          .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StockHistoryModel>> getStockHistory(
    int stockId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.stocks}/$stockId/history',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data
          .map((json) => StockHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StockModel> updateStock(UpdateStockParams params) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.stocks}/${params.stockId}',
        data: params.toJson(),
      );

      final data = response.data['data'] ?? response.data;
      return StockModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StockModel> adjustStock(StockAdjustmentParams params) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.stocks}/adjust',
        data: params.toJson(),
      );

      final data = response.data['data'] ?? response.data;
      return StockModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StockModel>> searchStocks(String query, {int? branchId}) async {
    final queryParams = <String, dynamic>{
      'search': query,
    };

    if (branchId != null) {
      queryParams['branch_id'] = branchId;
    }

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.stocks,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data
          .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
