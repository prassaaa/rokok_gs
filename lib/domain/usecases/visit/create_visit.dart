import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Create visit use case
class CreateVisit {
  final VisitRepository repository;

  CreateVisit(this.repository);

  Future<Either<Failure, Visit>> call(CreateVisitParams params) {
    return repository.createVisit(params);
  }
}
