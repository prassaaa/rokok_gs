import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/visit.dart';
import '../../models/pagination_model.dart';
import '../../models/visit_model.dart';

/// Remote data source for visits
abstract class VisitRemoteDataSource {
  /// Get paginated visits
  Future<PaginatedResponse<VisitModel>> getVisits({
    int page = 1,
    int perPage = 15,
    VisitStatus? status,
    VisitType? visitType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get visit by ID
  Future<VisitModel> getVisitById(int id);

  /// Get visits by sales ID
  Future<PaginatedResponse<VisitModel>> getVisitsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  });

  /// Create new visit
  Future<VisitModel> createVisit(CreateVisitParams params);

  /// Get visit statistics
  Future<VisitStatisticsModel> getStatistics();
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final ApiClient apiClient;

  VisitRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResponse<VisitModel>> getVisits({
    int page = 1,
    int perPage = 15,
    VisitStatus? status,
    VisitType? visitType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': _statusToString(status),
        if (visitType != null) 'visit_type': _visitTypeToString(visitType),
        if (startDate != null)
          'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null)
          'end_date': endDate.toIso8601String().split('T')[0],
      };

      final response = await apiClient.dio.get(
        ApiConstants.visits,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => VisitModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get visits',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitModel> getVisitById(int id) async {
    try {
      final response = await apiClient.dio.get(ApiConstants.visitDetail(id));

      final data = response.data;
      if (data['success'] == true) {
        return VisitModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get visit',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponse<VisitModel>> getVisitsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {'page': page, 'per_page': perPage};

      final response = await apiClient.dio.get(
        ApiConstants.visitsBySales(salesId),
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        return PaginatedResponse.fromJson(
          data,
          (json) => VisitModel.fromJson(json),
        );
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get visits',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitModel> createVisit(CreateVisitParams params) async {
    try {
      Response response;

      if (params.photoPath != null) {
        // Use multipart form data when there's a photo
        final formData = FormData.fromMap({
          ...params.toJson(),
          'photo': await MultipartFile.fromFile(
            params.photoPath!,
            filename: 'visit_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });

        response = await apiClient.dio.post(
          ApiConstants.visits,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        // Regular JSON request without photo
        response = await apiClient.dio.post(
          ApiConstants.visits,
          data: params.toJson(),
        );
      }

      final data = response.data;
      if (data['success'] == true) {
        return VisitModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to create visit',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitStatisticsModel> getStatistics() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.visitStatistics);

      final data = response.data;
      if (data['success'] == true) {
        return VisitStatisticsModel.fromJson(data['data']);
      } else {
        return const VisitStatisticsModel();
      }
    } on DioException {
      return const VisitStatisticsModel();
    }
  }

  String _statusToString(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return 'pending';
      case VisitStatus.approved:
        return 'approved';
      case VisitStatus.rejected:
        return 'rejected';
    }
  }

  String _visitTypeToString(VisitType type) {
    switch (type) {
      case VisitType.routine:
        return 'routine';
      case VisitType.prospecting:
        return 'prospecting';
      case VisitType.followUp:
        return 'follow_up';
      case VisitType.complaint:
        return 'complaint';
      case VisitType.other:
        return 'other';
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
        return ServerException(message: e.message ?? 'Something went wrong');
    }
  }
}
