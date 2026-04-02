import 'package:dio/dio.dart';
import '../../config/constants/api_constants.dart';
import 'api_interceptors.dart';
import 'retry_interceptor.dart';
import 'network_info.dart';
import '../storage/secure_storage.dart';

/// Dio API Client for Guyub Mobile
/// Handles all HTTP requests with auth, logging, error handling, and retry
class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;
  final NetworkInfo? _networkInfo;

  ApiClient({
    required SecureStorageService storage,
    NetworkInfo? networkInfo,
    String? baseUrl,
  }) : _storage = storage,
       _networkInfo = networkInfo {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.acceptHeader,
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(storage: _storage, dio: _dio),
      // Retry interceptor for automatic retry on network errors
      RetryInterceptor(
        dio: _dio,
        networkInfo: _networkInfo,
        config: const RetryConfig(
          maxRetries: 3,
          retryInterval: Duration(seconds: 1),
          retryOnConnectionError: true,
          retryOnTimeout: true,
        ),
      ),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Upload file with multipart/form-data
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formDataMap = <String, dynamic>{...?data};
    formDataMap[fieldName] = await MultipartFile.fromFile(filePath);

    final formData = FormData.fromMap(formDataMap);

    return _dio.post<T>(
      path,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  /// Upload multiple files
  Future<Response<T>> uploadFiles<T>(
    String path, {
    required List<String> filePaths,
    required String fieldName,
    Map<String, dynamic>? data,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formDataMap = <String, dynamic>{...?data};
    formDataMap[fieldName] = files;

    final formData = FormData.fromMap(formDataMap);

    return _dio.post<T>(
      path,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response> downloadFile(
    String url,
    String savePath, {
    Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) {
    return _dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  /// Update base URL (e.g., for switching environments)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Get underlying Dio instance (for advanced use cases)
  Dio get dio => _dio;
}
