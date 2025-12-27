import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/commission_model.dart';
import '../../../domain/entities/commission.dart';

/// Remote data source for commission operations
abstract class CommissionRemoteDataSource {
  /// Get commissions
  Future<List<CommissionModel>> getCommissions({
    DateTime? startDate,
    DateTime? endDate,
    CommissionStatus? status,
    int page = 1,
    int perPage = 20,
  });

  /// Get commission summary
  Future<CommissionSummaryModel> getCommissionSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get commission by ID
  Future<CommissionModel> getCommissionById(int id);
}

/// Implementation of CommissionRemoteDataSource
class CommissionRemoteDataSourceImpl implements CommissionRemoteDataSource {
  final ApiClient _apiClient;

  CommissionRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CommissionModel>> getCommissions({
    DateTime? startDate,
    DateTime? endDate,
    CommissionStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T').first;
    }
    if (status != null) {
      queryParams['status'] = status.value;
    }

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.commissions,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data
          .map((json) => CommissionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CommissionSummaryModel> getCommissionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T').first;
    }

    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.commissions}/summary',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data['data'] ?? response.data;
      return CommissionSummaryModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CommissionModel> getCommissionById(int id) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.commissions}/$id',
      );

      final data = response.data['data'] ?? response.data;
      return CommissionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
