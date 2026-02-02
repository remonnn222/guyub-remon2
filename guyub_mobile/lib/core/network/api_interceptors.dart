import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/constants/api_constants.dart';
import '../../config/constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../error/exceptions.dart';

/// Auth Interceptor
/// Handles JWT token injection and auto-refresh on 401
class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;
  final Dio dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({required this.storage, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login and refresh endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers[ApiConstants.authHeader] =
          '${ApiConstants.bearerPrefix} $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isPublicEndpoint(err.requestOptions.path)) {
      // Try to refresh token
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await storage.getRefreshToken();
          if (refreshToken != null) {
            // Request new tokens
            final response = await dio.post(
              ApiConstants.refresh,
              data: {'refresh_token': refreshToken},
              options: Options(
                headers: {
                  'Content-Type': ApiConstants.contentType,
                },
              ),
            );

            if (response.statusCode == 200) {
              final newAccessToken = response.data['data']['access_token'];
              final newRefreshToken = response.data['data']['refresh_token'];

              // Save new tokens
              await storage.setAccessToken(newAccessToken);
              await storage.setRefreshToken(newRefreshToken);

              // Retry original request
              err.requestOptions.headers[ApiConstants.authHeader] =
                  '${ApiConstants.bearerPrefix} $newAccessToken';

              final retryResponse = await dio.fetch(err.requestOptions);
              _isRefreshing = false;

              // Process pending requests
              _processPendingRequests(newAccessToken);

              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          // Refresh failed, clear tokens and trigger logout
          await storage.clearTokens();
          _isRefreshing = false;
          _pendingRequests.clear();
        }

        _isRefreshing = false;
      } else {
        // Queue the request while refreshing
        _pendingRequests.add(err.requestOptions);
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path == ApiConstants.login ||
        path == ApiConstants.refresh ||
        path == ApiConstants.health;
  }

  void _processPendingRequests(String token) async {
    for (final request in _pendingRequests) {
      request.headers[ApiConstants.authHeader] =
          '${ApiConstants.bearerPrefix} $token';
      try {
        await dio.fetch(request);
      } catch (_) {
        // Ignore errors for queued requests
      }
    }
    _pendingRequests.clear();
  }
}

/// Logging Interceptor
/// Logs requests and responses for debugging
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '📤 REQUEST[${options.method}] => PATH: ${options.path}\n'
      'Headers: ${options.headers}\n'
      'Query: ${options.queryParameters}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\n'
      'Message: ${err.message}\n'
      'Response: ${err.response?.data}',
    );
    handler.next(err);
  }
}

/// Error Interceptor
/// Transforms DioExceptions into app-specific exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _transformError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  AppException _transformError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: AppConstants.errorTimeout,
          statusCode: null,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: AppConstants.errorNetwork,
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(err);

      case DioExceptionType.cancel:
        return AppException(
          message: 'Permintaan dibatalkan.',
          statusCode: null,
        );

      default:
        return AppException(
          message: AppConstants.errorGeneric,
          statusCode: null,
        );
    }
  }

  AppException _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Try to extract error message from response
    String message = AppConstants.errorGeneric;
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          errors: data is Map<String, dynamic> ? data['errors'] : null,
        );

      case 401:
        return UnauthorizedException(
          message: message.isNotEmpty ? message : AppConstants.errorUnauthorized,
          statusCode: statusCode,
        );

      case 403:
        return ForbiddenException(
          message: message.isNotEmpty ? message : AppConstants.errorForbidden,
          statusCode: statusCode,
        );

      case 404:
        return NotFoundException(
          message: message.isNotEmpty ? message : AppConstants.errorNotFound,
          statusCode: statusCode,
        );

      case 422:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          errors: data is Map<String, dynamic> ? data['errors'] : null,
        );

      case 429:
        return RateLimitException(
          message: 'Terlalu banyak permintaan. Silakan coba lagi nanti.',
          statusCode: statusCode,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: AppConstants.errorServer,
          statusCode: statusCode,
        );

      default:
        return AppException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}
