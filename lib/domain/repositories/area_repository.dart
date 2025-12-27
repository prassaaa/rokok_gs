import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/area.dart';

/// Repository interface for Area operations
abstract class AreaRepository {
  /// Get all areas (Sales sees assigned areas, Admin/Manager sees all)
  Future<Either<Failure, List<Area>>> getAreas();

  /// Get area by ID
  Future<Either<Failure, Area>> getAreaById(int id);
}
