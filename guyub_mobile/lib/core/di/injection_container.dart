import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage.dart';
import '../storage/token_manager.dart';
import '../security/biometric_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/family/data/datasources/family_remote_datasource.dart';
import '../../features/family/data/datasources/family_local_datasource.dart';
import '../../features/family/data/repositories/family_repository_impl.dart';
import '../../features/family/domain/repositories/family_repository.dart';

/// Service Locator
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // ===================
  // CORE
  // ===================

  // Storage
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Token Manager (for JWT validation)
  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(storage: sl()),
  );

  // Biometric Service
  sl.registerLazySingleton<BiometricService>(
    () => BiometricService(storage: sl()),
  );

  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: sl(),
      networkInfo: sl(), // Pass NetworkInfo for retry logic
    ),
  );

  // ===================
  // AUTH FEATURE
  // ===================

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // ===================
  // FAMILY FEATURE
  // ===================

  // Data Sources
  sl.registerLazySingleton<FamilyRemoteDataSource>(
    () => FamilyRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<FamilyLocalDataSource>(
    () => FamilyLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<FamilyRepository>(
    () => FamilyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ===================
  // USER FEATURE
  // ===================
  // TODO: Add user feature dependencies
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
