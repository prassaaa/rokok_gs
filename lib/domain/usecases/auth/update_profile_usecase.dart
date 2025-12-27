import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Update Profile UseCase
class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
      avatarPath: params.avatarPath,
    );
  }
}

/// Update profile parameters
class UpdateProfileParams extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;
  final String? avatarPath;

  const UpdateProfileParams({
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.passwordConfirmation,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
        avatarPath,
      ];
}
