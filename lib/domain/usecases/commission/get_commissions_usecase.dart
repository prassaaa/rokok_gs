import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/commission.dart';
import '../../repositories/commission_repository.dart';

/// Use case for getting commissions
class GetCommissionsUseCase {
  final CommissionRepository _repository;

  GetCommissionsUseCase(this._repository);

  Future<Either<Failure, List<Commission>>> call({
    DateTime? startDate,
    DateTime? endDate,
    CommissionStatus? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.getCommissions(
      startDate: startDate,
      endDate: endDate,
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}
