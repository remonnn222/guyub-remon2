import 'dart:async';
import 'dart:collection';

/// Rate Limiter
/// Prevents excessive API calls and protects against brute force attempts
class RateLimiter {
  final int maxAttempts;
  final Duration window;
  final Duration? lockoutDuration;

  final Queue<DateTime> _attempts = Queue<DateTime>();
  DateTime? _lockedUntil;

  RateLimiter({
    this.maxAttempts = 5,
    this.window = const Duration(minutes: 1),
    this.lockoutDuration,
  });

  /// Check if action is allowed
  bool get isAllowed {
    _cleanupOldAttempts();

    // Check if locked out
    if (_lockedUntil != null) {
      if (DateTime.now().isBefore(_lockedUntil!)) {
        return false;
      }
      // Lockout expired, reset
      _lockedUntil = null;
      _attempts.clear();
    }

    return _attempts.length < maxAttempts;
  }

  /// Record an attempt
  void recordAttempt() {
    _cleanupOldAttempts();
    _attempts.add(DateTime.now());

    // If exceeded, apply lockout
    if (_attempts.length >= maxAttempts && lockoutDuration != null) {
      _lockedUntil = DateTime.now().add(lockoutDuration!);
    }
  }

  /// Get remaining attempts
  int get remainingAttempts {
    _cleanupOldAttempts();
    return (maxAttempts - _attempts.length).clamp(0, maxAttempts);
  }

  /// Get time until lockout expires
  Duration? get lockoutRemaining {
    if (_lockedUntil == null) return null;
    final remaining = _lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Check if currently locked out
  bool get isLockedOut {
    if (_lockedUntil == null) return false;
    return DateTime.now().isBefore(_lockedUntil!);
  }

  /// Reset the rate limiter
  void reset() {
    _attempts.clear();
    _lockedUntil = null;
  }

  void _cleanupOldAttempts() {
    final cutoff = DateTime.now().subtract(window);
    while (_attempts.isNotEmpty && _attempts.first.isBefore(cutoff)) {
      _attempts.removeFirst();
    }
  }
}

/// Login Rate Limiter
/// Specialized rate limiter for login attempts
class LoginRateLimiter extends RateLimiter {
  LoginRateLimiter()
      : super(
          maxAttempts: 5,
          window: const Duration(minutes: 5),
          lockoutDuration: const Duration(minutes: 15),
        );

  /// Get user-friendly lockout message
  String get lockoutMessage {
    final remaining = lockoutRemaining;
    if (remaining == null) return '';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return 'Terlalu banyak percobaan. Coba lagi dalam $minutes menit $seconds detik.';
    }
    return 'Terlalu banyak percobaan. Coba lagi dalam $seconds detik.';
  }

  /// Get warning message before lockout
  String get warningMessage {
    final remaining = remainingAttempts;
    if (remaining <= 2 && remaining > 0) {
      return 'Peringatan: Sisa $remaining percobaan sebelum akun terkunci.';
    }
    return '';
  }
}

/// API Rate Limiter
/// General rate limiter for API calls
class ApiRateLimiter {
  final Map<String, RateLimiter> _limiters = {};

  /// Get or create a rate limiter for an endpoint
  RateLimiter forEndpoint(
    String endpoint, {
    int maxAttempts = 60,
    Duration window = const Duration(minutes: 1),
  }) {
    return _limiters.putIfAbsent(
      endpoint,
      () => RateLimiter(maxAttempts: maxAttempts, window: window),
    );
  }

  /// Check if endpoint call is allowed
  bool isAllowed(String endpoint) {
    final limiter = _limiters[endpoint];
    return limiter?.isAllowed ?? true;
  }

  /// Record an API call
  void record(String endpoint) {
    _limiters[endpoint]?.recordAttempt();
  }

  /// Reset specific endpoint
  void resetEndpoint(String endpoint) {
    _limiters[endpoint]?.reset();
  }

  /// Reset all limiters
  void resetAll() {
    for (final limiter in _limiters.values) {
      limiter.reset();
    }
  }
}

/// Debouncer
/// Prevents rapid successive calls
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  /// Run action after debounce duration
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler
/// Limits how often an action can run
class Throttler {
  final Duration duration;
  DateTime? _lastRun;

  Throttler({this.duration = const Duration(seconds: 1)});

  /// Run action if not throttled
  bool run(void Function() action) {
    final now = DateTime.now();

    if (_lastRun == null || now.difference(_lastRun!) >= duration) {
      _lastRun = now;
      action();
      return true;
    }

    return false;
  }

  /// Check if action would be throttled
  bool get isThrottled {
    if (_lastRun == null) return false;
    return DateTime.now().difference(_lastRun!) < duration;
  }

  /// Reset throttler
  void reset() {
    _lastRun = null;
  }
}
