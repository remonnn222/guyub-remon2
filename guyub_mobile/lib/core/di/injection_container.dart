import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage.dart';
import '../storage/token_manager.dart';
import '../security/biometric_service.dart';
import '../services/deep_link_service.dart';
import '../services/sync_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/family/data/datasources/family_remote_datasource.dart';
import '../../features/family/data/datasources/family_local_datasource.dart';
import '../../features/family/data/repositories/family_repository_impl.dart';
import '../../features/family/domain/repositories/family_repository.dart';
import '../../features/profile/data/datasources/asset_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../features/profile/domain/usecases/get_user_avatar_usecase.dart';
import '../../features/profile/domain/usecases/edit_profile_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../core/services/image_service.dart';
import '../../features/event/data/datasources/event_remote_datasource.dart';
import '../../features/event/data/datasources/event_local_datasource.dart';
import '../../features/event/data/repositories/event_repository_impl.dart';
import '../../features/event/domain/repositories/event_repository.dart';

/// Service Locator
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // ===================
  // CORE
  // ===================

  // Storage
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Token Manager (for JWT validation)
  sl.registerLazySingleton<TokenManager>(() => TokenManager(storage: sl()));

  // Biometric Service
  sl.registerLazySingleton<BiometricService>(
    () => BiometricService(storage: sl()),
  );

  // Deep Link Service
  sl.registerLazySingleton<DeepLinkService>(() => DeepLinkService());

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: sl(),
      networkInfo: sl(), // Pass NetworkInfo for retry logic
    ),
  );

  // Offline sync service
  sl.registerLazySingleton<SyncService>(
    () => SyncService(networkInfo: sl(), familyRepository: sl()),
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
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

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
  // PROFILE FEATURE
  // ===================

  // Data source for avatar management
  sl.registerLazySingleton<AssetRemoteDataSource>(
    () => AssetRemoteDataSourceImpl(apiClient: sl()),
  );

  // Profile Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      assetRemoteDataSource: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetUserAvatarUseCase(sl()));
  sl.registerLazySingleton(() => EditProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  // Image Service
  sl.registerLazySingleton<ImageService>(() => ImageService());

  // ===================
  // EVENT FEATURE **NEW**
  // ===================

  // Data Sources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ===================
  // USER FEATURE
  // ===================
  // User-related dependencies are handled through Auth feature (profile/update are in AuthRepository).
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
