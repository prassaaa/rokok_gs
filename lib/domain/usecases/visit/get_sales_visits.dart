import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Get visits by sales ID use case
class GetSalesVisits {
  final VisitRepository repository;

  GetSalesVisits(this.repository);

  Future<Either<Failure, PaginatedResponse<Visit>>> call({
    required int salesId,
    int page = 1,
    int perPage = 15,
  }) {
    return repository.getVisitsBySales(
      salesId: salesId,
      page: page,
      perPage: perPage,
    );
  }
}
