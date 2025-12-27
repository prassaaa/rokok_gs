import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/commission.dart';
import '../../domain/repositories/commission_repository.dart';
import '../datasources/remote/commission_remote_datasource.dart';

/// Implementation of CommissionRepository
class CommissionRepositoryImpl implements CommissionRepository {
  final CommissionRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  CommissionRepositoryImpl({
    required CommissionRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Commission>>> getCommissions({
    DateTime? startDate,
    DateTime? endDate,
    CommissionStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final commissions = await _remoteDataSource.getCommissions(
        startDate: startDate,
        endDate: endDate,
        status: status,
        page: page,
        perPage: perPage,
      );
      return Right(commissions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommissionSummary>> getCommissionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final summary = await _remoteDataSource.getCommissionSummary(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Commission>> getCommissionById(int id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final commission = await _remoteDataSource.getCommissionById(id);
      return Right(commission);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
