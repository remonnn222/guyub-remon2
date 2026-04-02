import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/asset_remote_datasource.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AssetRemoteDataSource assetRemoteDataSource;
  final AuthRepository authRepository;

  ProfileRepositoryImpl({
    required this.assetRemoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required File file,
    required int userId,
  }) async {
    try {
      final url = await assetRemoteDataSource.uploadUserAvatar(
        file: file,
        userId: userId,
      );
      return Right(url);
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getUserAvatarUrl({
    required int userId,
  }) async {
    try {
      final url = await assetRemoteDataSource.getUserAvatarUrl(userId: userId);
      return Right(url);
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? email,
  }) {
    return authRepository.updateProfile(name: name, email: email);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
