import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/repositories/area_repository.dart';
import '../datasources/remote/area_remote_datasource.dart';

/// Implementation of AreaRepository
class AreaRepositoryImpl implements AreaRepository {
  final AreaRemoteDataSource _remoteDataSource;

  AreaRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Area>>> getAreas() async {
    try {
      final areas = await _remoteDataSource.getAreas();
      return Right(areas);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Left(NetworkFailure());
      }
      return Left(ServerFailure(
        message: e.response?.data?['message'] ?? e.message ?? 'Server error',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Area>> getAreaById(int id) async {
    try {
      final area = await _remoteDataSource.getAreaById(id);
      return Right(area);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Left(NetworkFailure());
      }
      if (e.response?.statusCode == 404) {
        return Left(NotFoundFailure(message: 'Area not found'));
      }
      return Left(ServerFailure(
        message: e.response?.data?['message'] ?? e.message ?? 'Server error',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
