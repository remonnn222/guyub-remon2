import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../config/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';

/// Remote data source for asset operations
abstract class AssetRemoteDataSource {
  /// Upload user avatar asset
  /// Returns public asset URL
  Future<String> uploadUserAvatar({required File file, required int userId});

  /// Get user avatar URL by user ID
  Future<String?> getUserAvatarUrl({required int userId});
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final ApiClient apiClient;

  AssetRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> uploadUserAvatar({
    required File file,
    required int userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
        'kind': 'user_avatar',
        'ref_id': userId.toString(),
      });

      final response = await apiClient.post(
        ApiConstants.assetsUpload,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data['data'];
      final url = data['url'] as String?;

      if (url == null || url.isEmpty) {
        throw ServerException(
          message: 'Gagal mendapatkan URL avatar dari server.',
        );
      }

      return url;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Upload avatar gagal. Silakan coba lagi.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String?> getUserAvatarUrl({required int userId}) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.userAvatar, {
        'id': userId.toString(),
      });
      final response = await apiClient.get(endpoint);
      final data = response.data['data'];
      if (data == null) return null;
      return (data as Map<String, dynamic>)['url'] as String?;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(
        message: 'Gagal mengambil URL avatar.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
