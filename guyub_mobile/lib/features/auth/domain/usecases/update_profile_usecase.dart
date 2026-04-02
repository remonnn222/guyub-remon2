import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Update profile use case
/// Covers user profile updates in the auth/user feature
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  /// Execute profile update
  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    return repository.updateProfile(name: params.name, email: params.email);
  }
}

class UpdateProfileParams {
  final String name;
  final String? email;

  const UpdateProfileParams({required this.name, this.email});
}
