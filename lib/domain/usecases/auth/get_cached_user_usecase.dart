import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Get Cached User UseCase
class GetCachedUserUseCase {
  final AuthRepository repository;

  GetCachedUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCachedUser();
  }
}
