import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Logout Use Case
/// Handles user logout and session cleanup
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute logout
  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
