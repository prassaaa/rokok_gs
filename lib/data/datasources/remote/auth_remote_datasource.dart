import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<AuthResultModel> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int branchId,
    String? phone,
  });

  /// Get current user profile
  Future<UserModel> getProfile();

  /// Update user profile
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? passwordConfirmation,
    String? avatarPath,
  });

  /// Logout current user
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        return AuthResultModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int branchId,
    String? phone,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'branch_id': branchId,
          if (phone != null) 'phone': phone,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.profile);

      final data = response.data;
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? passwordConfirmation,
    String? avatarPath,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
      };

      if (phone != null) requestData['phone'] = phone;
      if (password != null && password.isNotEmpty) {
        requestData['password'] = password;
        requestData['password_confirmation'] = passwordConfirmation;
      }

      Response response;

      if (avatarPath != null) {
        // Use multipart form data for avatar upload
        final formData = FormData.fromMap({
          ...requestData,
          'avatar': await MultipartFile.fromFile(avatarPath),
        });
        response = await apiClient.dio.put(
          ApiConstants.profile,
          data: formData,
        );
      } else {
        response = await apiClient.dio.put(
          ApiConstants.profile,
          data: requestData,
        );
      }

      final data = response.data;
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: data['message'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.dio.post(ApiConstants.logout);

      final data = response.data;
      if (data['success'] != true) {
        throw ServerException(
          message: data['message'] ?? 'Logout failed',
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
