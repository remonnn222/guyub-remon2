// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Family List Notifier

@ProviderFor(FamilyListNotifier)
final familyListProvider = FamilyListNotifierProvider._();

/// Family List Notifier
final class FamilyListNotifierProvider
    extends $NotifierProvider<FamilyListNotifier, FamilyListState> {
  /// Family List Notifier
  FamilyListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyListNotifierHash();

  @$internal
  @override
  FamilyListNotifier create() => FamilyListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyListState>(value),
    );
  }
}

String _$familyListNotifierHash() =>
    r'a458be454b02bcc02136db687c4681d19309f692';

/// Family List Notifier

abstract class _$FamilyListNotifier extends $Notifier<FamilyListState> {
  FamilyListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FamilyListState, FamilyListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FamilyListState, FamilyListState>,
              FamilyListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Family Tree Notifier

@ProviderFor(FamilyTreeNotifier)
final familyTreeProvider = FamilyTreeNotifierFamily._();

/// Family Tree Notifier
final class FamilyTreeNotifierProvider
    extends $NotifierProvider<FamilyTreeNotifier, FamilyTreeState> {
  /// Family Tree Notifier
  FamilyTreeNotifierProvider._({
    required FamilyTreeNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'familyTreeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$familyTreeNotifierHash();

  @override
  String toString() {
    return r'familyTreeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FamilyTreeNotifier create() => FamilyTreeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyTreeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyTreeState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FamilyTreeNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$familyTreeNotifierHash() =>
    r'db4befc700060937e902c21af1c14f9706dac202';

/// Family Tree Notifier

final class FamilyTreeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FamilyTreeNotifier,
          FamilyTreeState,
          FamilyTreeState,
          FamilyTreeState,
          int
        > {
  FamilyTreeNotifierFamily._()
    : super(
        retry: null,
        name: r'familyTreeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Family Tree Notifier

  FamilyTreeNotifierProvider call(int familyId) =>
      FamilyTreeNotifierProvider._(argument: familyId, from: this);

  @override
  String toString() => r'familyTreeProvider';
}

/// Family Tree Notifier

abstract class _$FamilyTreeNotifier extends $Notifier<FamilyTreeState> {
  late final _$args = ref.$arg as int;
  int get familyId => _$args;

  FamilyTreeState build(int familyId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FamilyTreeState, FamilyTreeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FamilyTreeState, FamilyTreeState>,
              FamilyTreeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Person Form Notifier

@ProviderFor(PersonFormNotifier)
final personFormProvider = PersonFormNotifierProvider._();

/// Person Form Notifier
final class PersonFormNotifierProvider
    extends $NotifierProvider<PersonFormNotifier, PersonFormState> {
  /// Person Form Notifier
  PersonFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personFormNotifierHash();

  @$internal
  @override
  PersonFormNotifier create() => PersonFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersonFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersonFormState>(value),
    );
  }
}

String _$personFormNotifierHash() =>
    r'262737a09ab687d9df6346a03affc1cc5390ad96';

/// Person Form Notifier

abstract class _$PersonFormNotifier extends $Notifier<PersonFormState> {
  PersonFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PersonFormState, PersonFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PersonFormState, PersonFormState>,
              PersonFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Relationship Form Notifier

@ProviderFor(RelationshipFormNotifier)
final relationshipFormProvider = RelationshipFormNotifierProvider._();

/// Relationship Form Notifier
final class RelationshipFormNotifierProvider
    extends $NotifierProvider<RelationshipFormNotifier, RelationshipFormState> {
  /// Relationship Form Notifier
  RelationshipFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relationshipFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relationshipFormNotifierHash();

  @$internal
  @override
  RelationshipFormNotifier create() => RelationshipFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RelationshipFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RelationshipFormState>(value),
    );
  }
}

String _$relationshipFormNotifierHash() =>
    r'3dd7a6de8121955e56c876dbd4700547b4d32224';

/// Relationship Form Notifier

abstract class _$RelationshipFormNotifier
    extends $Notifier<RelationshipFormState> {
  RelationshipFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RelationshipFormState, RelationshipFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RelationshipFormState, RelationshipFormState>,
              RelationshipFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Selected Person Notifier (for detail view)

@ProviderFor(SelectedPersonNotifier)
final selectedPersonProvider = SelectedPersonNotifierProvider._();

/// Selected Person Notifier (for detail view)
final class SelectedPersonNotifierProvider
    extends $NotifierProvider<SelectedPersonNotifier, Person?> {
  /// Selected Person Notifier (for detail view)
  SelectedPersonNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPersonNotifierHash();

  @$internal
  @override
  SelectedPersonNotifier create() => SelectedPersonNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Person? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Person?>(value),
    );
  }
}

String _$selectedPersonNotifierHash() =>
    r'c0f3551060b5d3f6a51c4daf548b313bc24ba0fb';

/// Selected Person Notifier (for detail view)

abstract class _$SelectedPersonNotifier extends $Notifier<Person?> {
  Person? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Person?, Person?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Person?, Person?>,
              Person?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Tree View Mode Notifier (graph vs list)

@ProviderFor(TreeViewModeNotifier)
final treeViewModeProvider = TreeViewModeNotifierProvider._();

/// Tree View Mode Notifier (graph vs list)
final class TreeViewModeNotifierProvider
    extends $NotifierProvider<TreeViewModeNotifier, TreeViewMode> {
  /// Tree View Mode Notifier (graph vs list)
  TreeViewModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeViewModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeViewModeNotifierHash();

  @$internal
  @override
  TreeViewModeNotifier create() => TreeViewModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TreeViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TreeViewMode>(value),
    );
  }
}

String _$treeViewModeNotifierHash() =>
    r'0af65756c1e2474c47055a396ed83c1908ffbf18';

/// Tree View Mode Notifier (graph vs list)

abstract class _$TreeViewModeNotifier extends $Notifier<TreeViewMode> {
  TreeViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TreeViewMode, TreeViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TreeViewMode, TreeViewMode>,
              TreeViewMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
