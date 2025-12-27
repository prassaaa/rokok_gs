import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Create transaction use case
class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, Transaction>> call(CreateTransactionParams params) {
    return repository.createTransaction(params);
  }
}
