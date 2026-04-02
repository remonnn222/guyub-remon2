import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, (AuthTokens, User)>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final request = LoginRequest(email: email, password: password);
      final (tokens, user) = await remoteDataSource.login(request);

      // Save tokens and user to secure storage
      await secureStorage.setAccessToken(tokens.accessToken);
      await secureStorage.setRefreshToken(tokens.refreshToken);
      await secureStorage.saveUser(UserModel.fromEntity(user).toJson());

      return Right((tokens, user));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          message: e.message,
          statusCode: e.statusCode,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to call logout API if connected
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
    } catch (_) {}

    // Always clear local auth data
    await secureStorage.clearAuthData();
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final currentRefreshToken = await secureStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        return const Left(
          AuthFailure(
            message: 'Sesi Anda telah berakhir. Silakan login kembali.',
          ),
        );
      }

      final tokens = await remoteDataSource.refreshToken(currentRefreshToken);

      // Save new tokens
      await secureStorage.setAccessToken(tokens.accessToken);
      await secureStorage.setRefreshToken(tokens.refreshToken);

      return Right(tokens);
    } on UnauthorizedException catch (e) {
      await secureStorage.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // First try to get from cache
    final cachedUser = await secureStorage.getUser();

    if (!await networkInfo.isConnected) {
      if (cachedUser != null) {
        return Right(UserModel.fromJson(cachedUser));
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUser();

      // Update cache
      await secureStorage.saveUser(user.toJson());

      return Right(user);
    } on UnauthorizedException catch (e) {
      await secureStorage.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      // Return cached user if available
      if (cachedUser != null) {
        return Right(UserModel.fromJson(cachedUser));
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      if (cachedUser != null) {
        return Right(UserModel.fromJson(cachedUser));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final request = UpdateProfileRequest(name: name, email: email);
      final user = await remoteDataSource.updateProfile(request);

      // Update cache
      await secureStorage.saveUser(user.toJson());

      return Right(user);
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          message: e.message,
          statusCode: e.statusCode,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      await remoteDataSource.changePassword(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          message: e.message,
          statusCode: e.statusCode,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await secureStorage.isAuthenticated();
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.clearAuthData();
  }
}
