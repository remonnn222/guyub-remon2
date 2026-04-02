import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class GetUserAvatarUseCase {
  final ProfileRepository repository;

  GetUserAvatarUseCase(this.repository);

  Future<Either<Failure, String?>> call(int userId) {
    return repository.getUserAvatarUrl(userId: userId);
  }
}
