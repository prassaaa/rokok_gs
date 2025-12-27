import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/transaction_repository.dart';

/// Get today's transaction summary use case
class GetTodaySummary {
  final TransactionRepository repository;

  GetTodaySummary(this.repository);

  Future<Either<Failure, TransactionSummary>> call() {
    return repository.getTodaySummary();
  }
}
