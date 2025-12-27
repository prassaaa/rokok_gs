import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../usecase.dart';
import '../../entities/area.dart';
import '../../repositories/area_repository.dart';

/// UseCase for getting area by ID
class GetAreaById implements UseCase<Area, GetAreaByIdParams> {
  final AreaRepository repository;

  GetAreaById(this.repository);

  @override
  Future<Either<Failure, Area>> call(GetAreaByIdParams params) {
    return repository.getAreaById(params.id);
  }
}

class GetAreaByIdParams extends Equatable {
  final int id;

  const GetAreaByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
