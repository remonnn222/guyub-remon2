import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';

abstract class AssetRemoteDataSource {
  Future<String> uploadAvatar(File file, int userId);
  Future<String> getAvatarUrl(int userId);
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final ApiClient apiClient;

  AssetRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> uploadAvatar(File file, int userId) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'avatar_$userId.jpg',
        ),
        'user_id': userId,
        'type': 'avatar',
      });

      final response = await apiClient.post(
        '/api/v1/assets/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']['url'] as String;
      } else {
        throw ServerException(
          message: 'Failed to upload avatar',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error during upload',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> getAvatarUrl(int userId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/assets/user/$userId/avatar',
      );

      if (response.statusCode == 200) {
        return response.data['data']['url'] as String;
      } else {
        throw ServerException(
          message: 'Failed to get avatar URL',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
