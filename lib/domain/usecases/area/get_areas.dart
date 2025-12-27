import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../usecase.dart';
import '../../entities/area.dart';
import '../../repositories/area_repository.dart';

/// UseCase for getting all areas
class GetAreas implements UseCase<List<Area>, NoParams> {
  final AreaRepository repository;

  GetAreas(this.repository);

  @override
  Future<Either<Failure, List<Area>>> call(NoParams params) {
    return repository.getAreas();
  }
}
