import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Get transactions use case
class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, PaginatedResponse<Transaction>>> call({
    int page = 1,
    int perPage = 15,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) {
    return repository.getTransactions(
      page: page,
      perPage: perPage,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }
}
