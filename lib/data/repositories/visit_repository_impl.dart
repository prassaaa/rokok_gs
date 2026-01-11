import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/remote/visit_remote_datasource.dart';
import '../models/pagination_model.dart';

/// Implementation of VisitRepository
class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResponse<Visit>>> getVisits({
    int page = 1,
    int perPage = 15,
    VisitStatus? status,
    VisitType? visitType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getVisits(
        page: page,
        perPage: perPage,
        status: status,
        visitType: visitType,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(
        PaginatedResponse<Visit>(
          data: result.data.map((m) => m.toEntity()).toList(),
          meta: result.meta,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getVisitById(id);
      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<Visit>>> getVisitsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getVisitsBySales(
        salesId: salesId,
        page: page,
        perPage: perPage,
      );

      return Right(
        PaginatedResponse<Visit>(
          data: result.data.map((m) => m.toEntity()).toList(),
          meta: result.meta,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Visit>> createVisit(CreateVisitParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.createVisit(params);
      return Right(result.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VisitStatistics>> getStatistics() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getStatistics();
      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
