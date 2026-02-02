import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'network_info.dart';

/// Retry Interceptor Configuration
class RetryConfig {
  final int maxRetries;
  final Duration retryInterval;
  final Duration maxRetryDelay;
  final List<int> retryStatusCodes;
  final bool retryOnConnectionError;
  final bool retryOnTimeout;

  const RetryConfig({
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 10),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryOnConnectionError = true,
    this.retryOnTimeout = true,
  });
}

/// Retry Interceptor
/// Automatically retries failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final NetworkInfo? networkInfo;
  final RetryConfig config;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  RetryInterceptor({
    required this.dio,
    this.networkInfo,
    this.config = const RetryConfig(),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retryCount'] ?? 0;

    // Check if we should retry
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // Check network connectivity before retry
    if (networkInfo != null) {
      final isConnected = await networkInfo!.isConnected;
      if (!isConnected) {
        _logger.w('No network connection. Skipping retry.');
        return handler.next(err);
      }
    }

    // Calculate delay with exponential backoff
    final delay = _calculateDelay(retryCount);
    _logger.i(
      '🔄 Retry ${retryCount + 1}/${config.maxRetries} for ${requestOptions.path} '
      'after ${delay.inMilliseconds}ms',
    );

    // Wait before retry
    await Future.delayed(delay);

    // Update retry count
    requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // If retry also fails, pass to next handler
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // Check max retries
    if (retryCount >= config.maxRetries) {
      return false;
    }

    // Check if request was cancelled
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Check connection errors
    if (config.retryOnConnectionError) {
      if (err.type == DioExceptionType.connectionError ||
          err.error is SocketException) {
        return true;
      }
    }

    // Check timeout errors
    if (config.retryOnTimeout) {
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return true;
      }
    }

    // Check response status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && config.retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: delay = baseInterval * 2^retryCount
    final exponentialDelay = config.retryInterval * (1 << retryCount);

    // Cap at max delay
    if (exponentialDelay > config.maxRetryDelay) {
      return config.maxRetryDelay;
    }

    return exponentialDelay;
  }
}

/// Request Queue for offline support
/// Queues requests when offline and executes when online
class RequestQueue {
  final List<_QueuedRequest> _queue = [];
  final Dio dio;
  final NetworkInfo networkInfo;
  final Logger _logger = Logger();

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isProcessing = false;

  RequestQueue({
    required this.dio,
    required this.networkInfo,
  }) {
    _startListening();
  }

  void _startListening() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected && _queue.isNotEmpty && !_isProcessing) {
          _processQueue();
        }
      },
    );
  }

  /// Add request to queue
  Future<Response?> enqueue(RequestOptions options) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      // Execute immediately if online
      return dio.fetch(options);
    }

    // Queue for later if offline
    final completer = Completer<Response?>();
    _queue.add(_QueuedRequest(options: options, completer: completer));
    _logger.i('Request queued: ${options.path}');

    return completer.future;
  }

  /// Process all queued requests
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    _logger.i('Processing ${_queue.length} queued requests');

    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);

      try {
        final response = await dio.fetch(request.options);
        request.completer.complete(response);
      } catch (e) {
        request.completer.complete(null);
        _logger.e('Queued request failed: ${request.options.path}', error: e);
      }
    }

    _isProcessing = false;
  }

  /// Get queue status
  int get queueLength => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isProcessing => _isProcessing;

  /// Clear queue
  void clearQueue() {
    for (final request in _queue) {
      request.completer.complete(null);
    }
    _queue.clear();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    clearQueue();
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response?> completer;

  _QueuedRequest({
    required this.options,
    required this.completer,
  });
}
