import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/commission.dart';
import '../../repositories/commission_repository.dart';

/// Use case for getting commission summary
class GetCommissionSummaryUseCase {
  final CommissionRepository _repository;

  GetCommissionSummaryUseCase(this._repository);

  Future<Either<Failure, CommissionSummary>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getCommissionSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
