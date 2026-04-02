import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return repository.uploadAvatar(file: params.file, userId: params.userId);
  }
}

class UploadAvatarParams {
  final File file;
  final int userId;

  UploadAvatarParams({required this.file, required this.userId});
}
