import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Get transaction detail use case
class GetTransactionDetail {
  final TransactionRepository repository;

  GetTransactionDetail(this.repository);

  Future<Either<Failure, Transaction>> call(int id) {
    return repository.getTransactionById(id);
  }
}
