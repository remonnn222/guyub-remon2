import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class EditProfileUseCase {
  final ProfileRepository repository;

  EditProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(EditProfileParams params) {
    return repository.updateProfile(name: params.name, email: params.email);
  }
}

class EditProfileParams {
  final String name;
  final String? email;

  EditProfileParams({required this.name, this.email});
}
