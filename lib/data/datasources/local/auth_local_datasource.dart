import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

/// Local data source for authentication (caching)
abstract class AuthLocalDataSource {
  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Cache auth token
  Future<void> cacheToken(String token);

  /// Get cached token
  Future<String?> getToken();

  /// Clear all auth cache
  Future<void> clearCache();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Set logged in status
  Future<void> setLoggedIn(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(key: AppConstants.userKey, value: userJson);
    } catch (e) {
      throw const CacheException(message: 'Failed to cache user data');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await secureStorage.read(key: AppConstants.userKey);
      if (userJson == null) return null;
      
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw const CacheException(message: 'Failed to cache token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: AppConstants.userKey);
      await secureStorage.delete(key: AppConstants.tokenKey);
      await secureStorage.delete(key: AppConstants.isLoggedInKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear cache');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final value = await secureStorage.read(key: AppConstants.isLoggedInKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    try {
      await secureStorage.write(
        key: AppConstants.isLoggedInKey,
        value: value.toString(),
      );
    } catch (e) {
      throw const CacheException(message: 'Failed to set login status');
    }
  }
}
