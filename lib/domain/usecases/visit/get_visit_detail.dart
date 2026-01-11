import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Get visit detail use case
class GetVisitDetail {
  final VisitRepository repository;

  GetVisitDetail(this.repository);

  Future<Either<Failure, Visit>> call(int id) {
    return repository.getVisitById(id);
  }
}
