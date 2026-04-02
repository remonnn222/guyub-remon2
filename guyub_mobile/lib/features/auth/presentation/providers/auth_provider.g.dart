// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth State Notifier
/// Manages authentication state using Riverpod

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Auth State Notifier
/// Manages authentication state using Riverpod
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// Auth State Notifier
  /// Manages authentication state using Riverpod
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'0bfdaf84d3507f0c6640a7f40781d437bd90d5e4';

/// Auth State Notifier
/// Manages authentication state using Riverpod

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Current User Provider
/// Provides access to current authenticated user

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Current User Provider
/// Provides access to current authenticated user

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// Current User Provider
  /// Provides access to current authenticated user
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'ce3277a0d619c2bf040fe5a2bff854de5239be94';

/// Is Authenticated Provider

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Is Authenticated Provider

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Is Authenticated Provider
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'f811c14ed44cf8855206d937873d789b5c5b3025';

/// Is Loading Provider

@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = IsAuthLoadingProvider._();

/// Is Loading Provider

final class IsAuthLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Is Loading Provider
  IsAuthLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthLoadingHash() => r'39d16c70964891790202285c847ed4e9adbcd441';

/// Auth Error Provider

@ProviderFor(authError)
final authErrorProvider = AuthErrorProvider._();

/// Auth Error Provider

final class AuthErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Auth Error Provider
  AuthErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authErrorHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return authError(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$authErrorHash() => r'ba0574734b6ffa6e6c32ca42a775b84df8b541f2';

/// Check if biometric login is enabled

@ProviderFor(isBiometricEnabled)
final isBiometricEnabledProvider = IsBiometricEnabledProvider._();

/// Check if biometric login is enabled

final class IsBiometricEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if biometric login is enabled
  IsBiometricEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isBiometricEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isBiometricEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isBiometricEnabled(ref);
  }
}

String _$isBiometricEnabledHash() =>
    r'a3ca9fe866fca06b8322a742978f186dc0dc65da';

/// Get available biometric types on device

@ProviderFor(availableBiometrics)
final availableBiometricsProvider = AvailableBiometricsProvider._();

/// Get available biometric types on device

final class AvailableBiometricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppBiometricType>>,
          List<AppBiometricType>,
          FutureOr<List<AppBiometricType>>
        >
    with
        $FutureModifier<List<AppBiometricType>>,
        $FutureProvider<List<AppBiometricType>> {
  /// Get available biometric types on device
  AvailableBiometricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableBiometricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableBiometricsHash();

  @$internal
  @override
  $FutureProviderElement<List<AppBiometricType>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppBiometricType>> create(Ref ref) {
    return availableBiometrics(ref);
  }
}

String _$availableBiometricsHash() =>
    r'2fc7ecc3bb8ad2cc8f453b595d89a27c022ce0db';

/// Check if biometric is supported on device

@ProviderFor(isBiometricSupported)
final isBiometricSupportedProvider = IsBiometricSupportedProvider._();

/// Check if biometric is supported on device

final class IsBiometricSupportedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if biometric is supported on device
  IsBiometricSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isBiometricSupportedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isBiometricSupportedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isBiometricSupported(ref);
  }
}

String _$isBiometricSupportedHash() =>
    r'3810f827553877e1612bdcdc32dc6fcf7880165f';

/// Check if biometric is enrolled on device

@ProviderFor(isBiometricEnrolled)
final isBiometricEnrolledProvider = IsBiometricEnrolledProvider._();

/// Check if biometric is enrolled on device

final class IsBiometricEnrolledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if biometric is enrolled on device
  IsBiometricEnrolledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isBiometricEnrolledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isBiometricEnrolledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isBiometricEnrolled(ref);
  }
}

String _$isBiometricEnrolledHash() =>
    r'c5c13fa0ac171c65fb9fa127d11c957ec3962621';

/// Remember Me Provider - checks if user has enabled remember me

@ProviderFor(isRememberMeEnabled)
final isRememberMeEnabledProvider = IsRememberMeEnabledProvider._();

/// Remember Me Provider - checks if user has enabled remember me

final class IsRememberMeEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Remember Me Provider - checks if user has enabled remember me
  IsRememberMeEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isRememberMeEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isRememberMeEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isRememberMeEnabled(ref);
  }
}

String _$isRememberMeEnabledHash() =>
    r'87c1239e3d5f2268d9468b2fb32f9b6248fea77b';
