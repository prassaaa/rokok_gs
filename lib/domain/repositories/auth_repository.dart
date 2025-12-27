import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Abstract repository for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  /// Register new user (Sales)
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int branchId,
    String? phone,
  });

  /// Get current user profile
  Future<Either<Failure, User>> getProfile();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? passwordConfirmation,
    String? avatarPath,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get cached user
  Future<User?> getCachedUser();

  /// Get current token
  Future<String?> getToken();
}
