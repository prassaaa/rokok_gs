import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/pagination_model.dart';
import '../entities/visit.dart';

/// Abstract repository for visits
abstract class VisitRepository {
  /// Get paginated list of visits
  Future<Either<Failure, PaginatedResponse<Visit>>> getVisits({
    int page = 1,
    int perPage = 15,
    VisitStatus? status,
    VisitType? visitType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get visit by ID
  Future<Either<Failure, Visit>> getVisitById(int id);

  /// Get visits by sales ID
  Future<Either<Failure, PaginatedResponse<Visit>>> getVisitsBySales({
    required int salesId,
    int page = 1,
    int perPage = 15,
  });

  /// Create new visit
  Future<Either<Failure, Visit>> createVisit(CreateVisitParams params);

  /// Get visit statistics
  Future<Either<Failure, VisitStatistics>> getStatistics();
}
