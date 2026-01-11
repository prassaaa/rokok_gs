import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Get visits use case
class GetVisits {
  final VisitRepository repository;

  GetVisits(this.repository);

  Future<Either<Failure, PaginatedResponse<Visit>>> call({
    int page = 1,
    int perPage = 15,
    VisitStatus? status,
    VisitType? visitType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getVisits(
      page: page,
      perPage: perPage,
      status: status,
      visitType: visitType,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
