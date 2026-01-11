import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

/// Get visit statistics use case
class GetVisitStatistics {
  final VisitRepository repository;

  GetVisitStatistics(this.repository);

  Future<Either<Failure, VisitStatistics>> call() {
    return repository.getStatistics();
  }
}
