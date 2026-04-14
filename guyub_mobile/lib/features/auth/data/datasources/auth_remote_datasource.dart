import 'package:dio/dio.dart';
import '../../../../config/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';

/// Auth Remote Data Source
/// Handles API calls for authentication
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<(AuthTokensModel, UserModel)> login(LoginRequest request);

  /// Logout current user
  Future<void> logout();

  /// Refresh access token
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Get current user data
  Future<UserModel> getCurrentUser();

  /// Update user profile
  Future<UserModel> updateProfile(UpdateProfileRequest request);

  /// Change password
  Future<void> changePassword(ChangePasswordRequest request);
}

/// Auth Remote Data Source Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<(AuthTokensModel, UserModel)> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
        options: Options(extra: {'noRetry': true}),
      );

      final data = response.data['data'];
      final tokens = AuthTokensModel.fromJson(data);
      final user = UserModel.fromJson(data['user']);

      return (tokens, user);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Login gagal. Silakan coba lagi.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logout);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'noRetry': true}),
      );

      return AuthTokensModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw UnauthorizedException(
        message: 'Sesi Anda telah berakhir. Silakan login kembali.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(
        ApiConstants.me,
        options: Options(extra: {'noRetry': true}),
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Gagal mengambil data user.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await apiClient.put(
        ApiConstants.profile,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Gagal memperbarui profil.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await apiClient.post(ApiConstants.changePassword, data: request.toJson());
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Gagal mengubah password.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
