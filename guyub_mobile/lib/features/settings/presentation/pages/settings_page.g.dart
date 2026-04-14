// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Environment Notifier

@ProviderFor(EnvironmentNotifier)
final environmentProvider = EnvironmentNotifierProvider._();

/// Environment Notifier
final class EnvironmentNotifierProvider
    extends $NotifierProvider<EnvironmentNotifier, Environment> {
  /// Environment Notifier
  EnvironmentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentNotifierHash();

  @$internal
  @override
  EnvironmentNotifier create() => EnvironmentNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Environment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Environment>(value),
    );
  }
}

String _$environmentNotifierHash() =>
    r'145734b91d88f4e85e70e4e3026626fbbd69784a';

/// Environment Notifier

abstract class _$EnvironmentNotifier extends $Notifier<Environment> {
  Environment build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Environment, Environment>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Environment, Environment>,
              Environment,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Biometric Settings Notifier

@ProviderFor(BiometricNotifier)
final biometricProvider = BiometricNotifierProvider._();

/// Biometric Settings Notifier
final class BiometricNotifierProvider
    extends $AsyncNotifierProvider<BiometricNotifier, Map<String, dynamic>> {
  /// Biometric Settings Notifier
  BiometricNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricNotifierHash();

  @$internal
  @override
  BiometricNotifier create() => BiometricNotifier();
}

String _$biometricNotifierHash() => r'f0e1c3c0a59e9ace30495a4df479fa664f4012f7';

/// Biometric Settings Notifier

abstract class _$BiometricNotifier
    extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>>,
                Map<String, dynamic>
              >,
              AsyncValue<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
