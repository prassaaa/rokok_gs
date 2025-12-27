import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/pagination_model.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Get transactions by sales ID use case
class GetSalesTransactions {
  final TransactionRepository repository;

  GetSalesTransactions(this.repository);

  Future<Either<Failure, PaginatedResponse<Transaction>>> call({
    required int salesId,
    int page = 1,
    int perPage = 15,
  }) {
    return repository.getTransactionsBySales(
      salesId: salesId,
      page: page,
      perPage: perPage,
    );
  }
}
