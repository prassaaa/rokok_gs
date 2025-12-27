import '../../repositories/auth_repository.dart';

/// Check Auth Status UseCase (not using Either because it's simple bool check)
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}
