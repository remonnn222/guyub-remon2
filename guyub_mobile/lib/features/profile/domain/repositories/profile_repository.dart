import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, String>> uploadAvatar({
    required File file,
    required int userId,
  });
  Future<Either<Failure, String?>> getUserAvatarUrl({required int userId});
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? email,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
