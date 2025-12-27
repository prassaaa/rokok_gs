import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';

/// Base UseCase with parameters
abstract class UseCase<type, Params> {
  Future<Either<Failure, type>> call(Params params);
}

/// For usecases that don't need parameters
class NoParams {
  const NoParams();
}
