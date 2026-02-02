import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Get Current User Use Case
/// Retrieves the currently authenticated user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Execute get current user
  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}
