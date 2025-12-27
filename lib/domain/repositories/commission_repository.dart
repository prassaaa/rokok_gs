import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/commission.dart';

/// Repository interface for commission operations
abstract class CommissionRepository {
  /// Get commissions for current user
  Future<Either<Failure, List<Commission>>> getCommissions({
    DateTime? startDate,
    DateTime? endDate,
    CommissionStatus? status,
    int page = 1,
    int perPage = 20,
  });

  /// Get commission summary
  Future<Either<Failure, CommissionSummary>> getCommissionSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get commission by ID
  Future<Either<Failure, Commission>> getCommissionById(int id);
}
