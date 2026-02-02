import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/family.dart';
import '../../domain/repositories/family_repository.dart';
import 'family_state.dart';

part 'family_provider.g.dart';

/// Family Repository Provider
final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return sl<FamilyRepository>();
});

/// Family List Notifier
@riverpod
class FamilyListNotifier extends _$FamilyListNotifier {
  @override
  FamilyListState build() {
    loadFamilies();
    return const FamilyListInitial();
  }

  FamilyRepository get _repository => ref.read(familyRepositoryProvider);

  Future<void> loadFamilies() async {
    state = const FamilyListLoading();

    final result = await _repository.getFamilies();

    result.fold(
      (failure) => state = FamilyListError(failure.message),
      (families) => state = FamilyListLoaded(families: families),
    );
  }

  Future<void> createFamily(CreateFamilyParams params) async {
    final currentState = state;
    state = const FamilyListLoading();

    final result = await _repository.createFamily(params);

    result.fold(
      (failure) => state = FamilyListError(failure.message),
      (newFamily) {
        if (currentState is FamilyListLoaded) {
          state = FamilyListLoaded(
            families: [newFamily, ...currentState.families],
          );
        } else {
          loadFamilies();
        }
      },
    );
  }

  Future<void> joinFamily(String inviteCode) async {
    state = const FamilyListLoading();

    final result = await _repository.joinFamily(inviteCode);

    result.fold(
      (failure) => state = FamilyListError(failure.message),
      (_) => loadFamilies(),
    );
  }

  Future<void> deleteFamily(int id) async {
    final currentState = state;

    final result = await _repository.deleteFamily(id);

    result.fold(
      (failure) => state = FamilyListError(failure.message),
      (_) {
        if (currentState is FamilyListLoaded) {
          state = FamilyListLoaded(
            families: currentState.families.where((f) => f.id != id).toList(),
          );
        }
      },
    );
  }
}

/// Family Tree Notifier
@riverpod
class FamilyTreeNotifier extends _$FamilyTreeNotifier {
  int? _currentFamilyId;

  @override
  FamilyTreeState build(int familyId) {
    _currentFamilyId = familyId;
    loadFamilyTree(familyId);
    return const FamilyTreeInitial();
  }

  FamilyRepository get _repository => ref.read(familyRepositoryProvider);

  Future<void> loadFamilyTree(int familyId) async {
    _currentFamilyId = familyId;
    state = const FamilyTreeLoading();

    final result = await _repository.getFamilyTree(familyId);

    result.fold(
      (failure) => state = FamilyTreeError(failure.message),
      (treeData) => state = FamilyTreeLoaded(treeData: treeData),
    );
  }

  void selectPerson(Person? person) {
    if (state is FamilyTreeLoaded) {
      state = (state as FamilyTreeLoaded).copyWith(selectedPerson: person);
    }
  }

  void clearSelection() {
    if (state is FamilyTreeLoaded) {
      final current = state as FamilyTreeLoaded;
      state = FamilyTreeLoaded(
        treeData: current.treeData,
        isOffline: current.isOffline,
        selectedPerson: null,
      );
    }
  }

  Future<void> refresh() async {
    if (_currentFamilyId != null) {
      await loadFamilyTree(_currentFamilyId!);
    }
  }

  Future<void> updatePositions(List<TreePosition> positions) async {
    if (_currentFamilyId == null) return;

    final result = await _repository.updateTreePositions(_currentFamilyId!, positions);

    result.fold(
      (failure) {
        // Silently fail, positions are saved locally
      },
      (_) {
        // Success - positions saved
      },
    );
  }
}

/// Person Form Notifier
@riverpod
class PersonFormNotifier extends _$PersonFormNotifier {
  @override
  PersonFormState build() => const PersonFormInitial();

  FamilyRepository get _repository => ref.read(familyRepositoryProvider);

  Future<void> createPerson(CreatePersonParams params) async {
    state = const PersonFormLoading();

    final result = await _repository.createPerson(params);

    result.fold(
      (failure) => state = PersonFormError(failure.message),
      (person) => state = PersonFormSuccess(
        person: person,
        message: 'Anggota keluarga berhasil ditambahkan',
      ),
    );
  }

  Future<void> updatePerson(int id, UpdatePersonParams params) async {
    state = const PersonFormLoading();

    final result = await _repository.updatePerson(id, params);

    result.fold(
      (failure) => state = PersonFormError(failure.message),
      (person) => state = PersonFormSuccess(
        person: person,
        message: 'Data anggota keluarga berhasil diperbarui',
      ),
    );
  }

  Future<void> deletePerson(int id) async {
    state = const PersonFormLoading();

    final result = await _repository.deletePerson(id);

    result.fold(
      (failure) => state = PersonFormError(failure.message),
      (_) => state = const PersonFormInitial(),
    );
  }

  void reset() {
    state = const PersonFormInitial();
  }
}

/// Relationship Form Notifier
@riverpod
class RelationshipFormNotifier extends _$RelationshipFormNotifier {
  @override
  RelationshipFormState build() => const RelationshipFormInitial();

  FamilyRepository get _repository => ref.read(familyRepositoryProvider);

  Future<void> createRelationship(CreateRelationshipParams params) async {
    state = const RelationshipFormLoading();

    final result = await _repository.createRelationship(params);

    result.fold(
      (failure) => state = RelationshipFormError(failure.message),
      (_) => state = const RelationshipFormSuccess('Hubungan berhasil ditambahkan'),
    );
  }

  Future<void> deleteRelationship(int id) async {
    state = const RelationshipFormLoading();

    final result = await _repository.deleteRelationship(id);

    result.fold(
      (failure) => state = RelationshipFormError(failure.message),
      (_) => state = const RelationshipFormSuccess('Hubungan berhasil dihapus'),
    );
  }

  void reset() {
    state = const RelationshipFormInitial();
  }
}

/// Tree View Mode Enum
enum TreeViewMode {
  auto,  // Switch based on screen size
  graph, // Always show graph view
  list,  // Always show list view
}

/// Selected Person Notifier (for detail view)
@riverpod
class SelectedPersonNotifier extends _$SelectedPersonNotifier {
  @override
  Person? build() => null;

  void select(Person? person) {
    state = person;
  }

  void clear() {
    state = null;
  }
}

/// Tree View Mode Notifier (graph vs list)
@riverpod
class TreeViewModeNotifier extends _$TreeViewModeNotifier {
  @override
  TreeViewMode build() => TreeViewMode.auto;

  void setMode(TreeViewMode mode) {
    state = mode;
  }

  void toggle(bool showGraphView) {
    state = switch (state) {
      TreeViewMode.auto => showGraphView ? TreeViewMode.list : TreeViewMode.graph,
      TreeViewMode.graph => TreeViewMode.list,
      TreeViewMode.list => TreeViewMode.graph,
    };
  }
}
