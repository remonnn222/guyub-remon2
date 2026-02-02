# Guyub Mobile

**Family Tree & Genealogy Platform - Flutter Mobile Application**

A Flutter mobile app for the Guyub platform, enabling families to preserve their history and strengthen bonds across generations with interactive family tree visualization.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [State Management](#state-management)
- [Security Features](#security-features)
- [API Integration](#api-integration)
- [Offline Support](#offline-support)
- [Testing](#testing)
- [Build & Deployment](#build--deployment)

---

## Features

### Core Features
- **Family Tree Visualization** - Interactive tree view with graph and list modes
- **Person Management** - Add, edit, delete family members with full profiles
- **Relationship Management** - Connect family members (parent, child, spouse, sibling)
- **Multi-Family Support** - Manage multiple family trees

### Security Features
- **Biometric Authentication** - Fingerprint and Face ID support
- **Secure Token Storage** - Encrypted storage with flutter_secure_storage
- **Rate Limiting** - Brute force protection (5 attempts/5min, 15min lockout)
- **Input Sanitization** - XSS/SQL injection prevention
- **JWT Validation** - Token expiry checking and auto-refresh

### UX Features
- **Offline-First** - SQLite local cache with sync queue
- **Pull-to-Refresh** - Refresh data with gesture
- **Loading States** - Shimmer loading, overlays, retry widgets
- **Connectivity Awareness** - Offline banner and request queueing

---

## Architecture

The app follows **Clean Architecture** with clear separation of concerns:

```
+-------------------------------------------------------------+
|                    PRESENTATION LAYER                        |
|  (Pages, Widgets, Riverpod Providers)                       |
|  - UI components                                            |
|  - State management via Riverpod                            |
|  - User interactions                                        |
+-------------------------------------------------------------+
|                    DOMAIN LAYER                              |
|  (Entities, Use Cases, Repository Interfaces)               |
|  - Business logic                                           |
|  - Use case implementations                                 |
|  - Abstract repository contracts                            |
+-------------------------------------------------------------+
|                      DATA LAYER                              |
|  (Models, Data Sources, Repository Implementations)         |
|  - API clients                                              |
|  - Local database                                           |
|  - Data mapping                                             |
+-------------------------------------------------------------+
|                      CORE LAYER                              |
|  (Network, Storage, Security, Utils, DI)                    |
|  - Shared utilities                                         |
|  - Infrastructure services                                  |
|  - Dependency injection                                     |
+-------------------------------------------------------------+
```

### Data Flow

```
User Action -> Provider -> Use Case -> Repository -> DataSource -> API/DB
                |                                         |
                +<------------- Response -----------------+
```

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x / Dart 3.x |
| **State Management** | Riverpod 3.x with code generation |
| **Navigation** | GoRouter |
| **HTTP Client** | Dio with interceptors |
| **Local Storage** | SQLite (sqflite) + Hive |
| **Secure Storage** | flutter_secure_storage |
| **Biometric Auth** | local_auth |
| **DI** | GetIt + Injectable |
| **Serialization** | json_serializable + freezed |
| **Tree Visualization** | graphview |

---

## Project Structure

```
guyub_mobile/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── app.dart                    # MaterialApp configuration
│   │
│   ├── config/
│   │   ├── constants/
│   │   │   ├── api_constants.dart  # API URLs, headers, timeouts
│   │   │   └── app_constants.dart  # App-wide constants
│   │   ├── routes/
│   │   │   ├── app_router.dart     # GoRouter configuration
│   │   │   └── route_names.dart    # Route path constants
│   │   └── theme/
│   │       ├── app_colors.dart     # Color palette
│   │       ├── app_spacing.dart    # Spacing/padding constants
│   │       ├── app_theme.dart      # ThemeData configuration
│   │       └── app_typography.dart # Text styles
│   │
│   ├── core/
│   │   ├── di/
│   │   │   └── injection_container.dart  # GetIt setup
│   │   ├── error/
│   │   │   ├── error_handler.dart  # Global error handling
│   │   │   ├── exceptions.dart     # Custom exceptions
│   │   │   └── failures.dart       # Failure types
│   │   ├── network/
│   │   │   ├── api_client.dart     # Dio HTTP client
│   │   │   ├── api_endpoints.dart  # API endpoint paths
│   │   │   ├── api_interceptors.dart # Auth, logging, error
│   │   │   ├── network_info.dart   # Connectivity checking
│   │   │   └── retry_interceptor.dart # Auto-retry logic
│   │   ├── security/
│   │   │   └── biometric_service.dart # Fingerprint/Face ID
│   │   ├── storage/
│   │   │   ├── local_database.dart # SQLite setup
│   │   │   ├── secure_storage.dart # Encrypted token storage
│   │   │   └── token_manager.dart  # JWT parsing/validation
│   │   └── utils/
│   │       ├── input_sanitizer.dart # Input validation
│   │       └── rate_limiter.dart   # Rate limiting utilities
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       └── providers/
│   │   │
│   │   ├── family/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── dashboard/
│   │   ├── profile/
│   │   └── settings/
│   │
│   └── shared/
│       ├── models/
│       └── widgets/
│
├── test/
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.x
- Android Studio / Xcode
- Backend server running (see main project)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd guyub/guyub_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (Riverpod, JSON serialization, Freezed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure environment**

   Edit `lib/config/constants/api_constants.dart`:
   ```dart
   class ApiConstants {
     // Local development
     static const String localUrl = 'http://localhost:8080/api/v1';

     // Android Emulator (10.0.2.2 maps to host localhost)
     static const String androidEmulatorUrl = 'http://10.0.2.2:8080/api/v1';

     // Production
     static const String productionUrl = 'https://api.guyub.id/api/v1';
   }
   ```

5. **Run the app**
   ```bash
   # Development
   flutter run

   # Specific device
   flutter run -d <device_id>
   ```

### iOS Setup (Biometric Auth)

Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Untuk login dengan Face ID</string>
```

### Android Setup (Biometric Auth)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

---

## Configuration

### Environment Switching

The app supports runtime environment switching via Settings page:

| Environment | URL | Use Case |
|-------------|-----|----------|
| Local | `http://localhost:8080` | iOS Simulator |
| Android Emulator | `http://10.0.2.2:8080` | Android Emulator |
| Production | `https://api.guyub.id` | Release builds |

### Timeouts

```dart
// api_constants.dart
static const int connectTimeout = 30000;  // 30 seconds
static const int receiveTimeout = 30000;  // 30 seconds
static const int sendTimeout = 30000;     // 30 seconds
```

---

## State Management

### Riverpod 3.x with Code Generation

```dart
// Provider definition
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    // ... login logic
  }
}

// Usage in widget
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);

    return authState.when(
      initial: () => LoginForm(),
      loading: () => LoadingIndicator(),
      authenticated: (user) => Dashboard(),
      error: (message) => ErrorView(message),
    );
  }
}
```

### State Classes with Freezed

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}
```

---

## Security Features

### 1. Rate Limiting

Prevents brute force attacks on login:

```dart
final loginRateLimiter = LoginRateLimiter();

// Configuration
maxAttempts: 5           // Max attempts allowed
window: Duration(minutes: 5)  // Time window
lockoutDuration: Duration(minutes: 15)  // Lockout period

// Usage
if (rateLimiter.isLockedOut) {
  showError(rateLimiter.lockoutMessage);
  return;
}
rateLimiter.recordAttempt();
```

### 2. Biometric Authentication

```dart
final biometricService = BiometricService(storage: secureStorage);

// Check availability
if (await biometricService.isSupported) {
  final result = await biometricService.authenticate(
    reason: 'Verify your identity',
  );

  if (result.isSuccess) {
    // Authenticated
  }
}
```

### 3. Token Management

```dart
final tokenManager = TokenManager(storage: secureStorage);

// Check token validity
final status = await tokenManager.getTokenStatus();
switch (status) {
  case TokenStatus.valid:
    // Proceed
  case TokenStatus.expiringSoon:
    // Refresh token
  case TokenStatus.expired:
    // Re-login required
}
```

### 4. Input Sanitization

```dart
// Email sanitization
final email = InputSanitizer.sanitizeEmail(input);

// Validation
final error = InputValidators.combine(value, [
  (v) => InputValidators.required(v, 'Email'),
  InputValidators.email,
]);
```

---

## API Integration

### Dio Client with Interceptors

```dart
ApiClient(
  storage: secureStorage,
  networkInfo: networkInfo,
);

// Interceptor chain:
// 1. AuthInterceptor - Adds JWT token
// 2. RetryInterceptor - Auto-retry on failure
// 3. LoggingInterceptor - Request/response logging
// 4. ErrorInterceptor - Error transformation
```

### Retry Logic

```dart
RetryInterceptor(
  dio: dio,
  networkInfo: networkInfo,
  config: RetryConfig(
    maxRetries: 3,
    retryInterval: Duration(seconds: 1),  // Exponential backoff
    retryOnConnectionError: true,
    retryOnTimeout: true,
    retryStatusCodes: [408, 429, 500, 502, 503, 504],
  ),
);
```

### Error Handling

```dart
// Exceptions are transformed to Failures
result.fold(
  (failure) => state = AuthState.error(failure.message),
  (user) => state = AuthState.authenticated(user),
);

// Failure types:
// - NetworkFailure
// - ServerFailure
// - CacheFailure
// - ValidationFailure
// - UnauthorizedFailure
```

---

## Offline Support

### Strategy

1. **Read**: Return local data first, sync in background
2. **Write**: Save locally immediately, queue for server sync
3. **Conflict**: Server wins (last-write-wins)

### Implementation

```dart
// Check connectivity
final isOnline = await networkInfo.isConnected;

if (isOnline) {
  // Fetch from server
  final data = await remoteDataSource.getFamilies();
  await localDataSource.cacheFamilies(data);
  return data;
} else {
  // Return cached data
  return await localDataSource.getCachedFamilies();
}
```

### Request Queue

```dart
final requestQueue = RequestQueue(
  dio: dio,
  networkInfo: networkInfo,
);

// Automatically processes when online
await requestQueue.enqueue(requestOptions);
```

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

### Test Structure

```
test/
├── unit/
│   ├── core/
│   ├── features/
│   └── shared/
├── widget/
│   └── features/
└── integration/
    └── app_test.dart
```

---

## Build & Deployment

### Development Build

```bash
# Debug APK
flutter build apk --debug

# Debug IPA (requires macOS)
flutter build ios --debug
```

### Release Build

```bash
# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

### Build Output Locations

| Platform | Location |
|----------|----------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android Bundle | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `build/ios/iphoneos/Runner.app` |

---

## Default Credentials

For development/testing:

```
Email: admin@guyub.id
Password: Admin@123
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Build runner errors | `dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs` |
| iOS build fails | `cd ios && pod install && cd ..` |
| Android gradle issues | `cd android && ./gradlew clean && cd ..` |
| Biometric not working | Check device has biometric enrolled, verify permissions |
| API connection refused | Check backend is running, verify API URL in settings |

### Logs

```bash
# Flutter logs
flutter logs

# Verbose mode
flutter run -v
```

---

## Contributing

1. Create feature branch from `dev`
2. Follow Clean Architecture patterns
3. Run `flutter analyze` before committing
4. Ensure all tests pass
5. Create PR to `dev` branch

---

## License

Proprietary - All rights reserved.

---

**Guyub** - *Togetherness in Family*
