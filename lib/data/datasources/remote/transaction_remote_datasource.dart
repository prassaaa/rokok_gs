import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../models/pagination_model.dart';
import '../../models/transaction_model.dart';

/// Remote data source for transactions
abstract class TransactionRemoteDataSource {
  /// Get paginated transactions
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int page = 1,
    int perPage = 15,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  });

  /// Get transaction by ID
  Future<TransactionModel> getTransactionById(int id);

  /// Get transactions by sales ID
  Future<PaginatedResponse<TransactionModel>> getTransactionsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  });

  /// Create new transaction
  Future<TransactionModel> createTransaction(CreateTransactionParams params);

  /// Get today's summary
  Future<TransactionSummary> getTodaySummary();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int page = 1,
    int perPage = 15,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (startDate != null)
          'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null)
          'end_date': endDate.toIso8601String().split('T')[0],
        if (status != null) 'status': TransactionStatusX.fromStatus(status),
      };

      final response = await apiClient.dio.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => TransactionModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get transactions',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> getTransactionById(int id) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.transactionDetail(id),
      );

      final data = response.data;
      if (data['success'] == true) {
        return TransactionModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get transaction',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponse<TransactionModel>> getTransactionsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
      };

      final response = await apiClient.dio.get(
        ApiConstants.transactionsBySales(salesId),
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => TransactionModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get transactions',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TransactionModel> createTransaction(
    CreateTransactionParams params,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.transactions,
        data: params.toJson(),
      );

      final data = response.data;
      if (data['success'] == true) {
        return TransactionModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to create transaction',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TransactionSummary> getTodaySummary() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await apiClient.dio.get(
        ApiConstants.transactions,
        queryParameters: {
          'start_date': today,
          'end_date': today,
          'summary': true,
        },
      );

      final data = response.data;
      if (data['success'] == true && data['summary'] != null) {
        return TransactionSummary.fromJson(data['summary']);
      }
      return const TransactionSummary();
    } on DioException {
      return const TransactionSummary();
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
        if (statusCode == 422) {
          Map<String, List<String>>? errors;
          if (data is Map && data['errors'] != null) {
            errors = (data['errors'] as Map).map(
              (key, value) => MapEntry(
                key.toString(),
                (value as List).map((e) => e.toString()).toList(),
              ),
            );
          }
          return ValidationException(message: message, errors: errors);
        }

        return ServerException.fromStatusCode(statusCode, message);
      default:
        return ServerException(
          message: e.message ?? 'Something went wrong',
        );
    }
  }
}
