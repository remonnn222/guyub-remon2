import 'package:equatable/equatable.dart';
import '../../domain/entities/family.dart';

/// Family List State
sealed class FamilyListState extends Equatable {
  const FamilyListState();

  @override
  List<Object?> get props => [];
}

class FamilyListInitial extends FamilyListState {
  const FamilyListInitial();
}

class FamilyListLoading extends FamilyListState {
  const FamilyListLoading();
}

class FamilyListLoaded extends FamilyListState {
  final List<Family> families;
  final bool isOffline;

  const FamilyListLoaded({
    required this.families,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [families, isOffline];
}

class FamilyListError extends FamilyListState {
  final String message;

  const FamilyListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Family Tree State
sealed class FamilyTreeState extends Equatable {
  const FamilyTreeState();

  @override
  List<Object?> get props => [];
}

class FamilyTreeInitial extends FamilyTreeState {
  const FamilyTreeInitial();
}

class FamilyTreeLoading extends FamilyTreeState {
  const FamilyTreeLoading();
}

class FamilyTreeLoaded extends FamilyTreeState {
  final FamilyTreeData treeData;
  final bool isOffline;
  final Person? selectedPerson;

  const FamilyTreeLoaded({
    required this.treeData,
    this.isOffline = false,
    this.selectedPerson,
  });

  FamilyTreeLoaded copyWith({
    FamilyTreeData? treeData,
    bool? isOffline,
    Person? selectedPerson,
  }) {
    return FamilyTreeLoaded(
      treeData: treeData ?? this.treeData,
      isOffline: isOffline ?? this.isOffline,
      selectedPerson: selectedPerson ?? this.selectedPerson,
    );
  }

  @override
  List<Object?> get props => [treeData, isOffline, selectedPerson];
}

class FamilyTreeError extends FamilyTreeState {
  final String message;

  const FamilyTreeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Person Form State
sealed class PersonFormState extends Equatable {
  const PersonFormState();

  @override
  List<Object?> get props => [];
}

class PersonFormInitial extends PersonFormState {
  const PersonFormInitial();
}

class PersonFormLoading extends PersonFormState {
  const PersonFormLoading();
}

class PersonFormSuccess extends PersonFormState {
  final Person person;
  final String message;

  const PersonFormSuccess({
    required this.person,
    required this.message,
  });

  @override
  List<Object?> get props => [person, message];
}

class PersonFormError extends PersonFormState {
  final String message;

  const PersonFormError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Relationship Form State
sealed class RelationshipFormState extends Equatable {
  const RelationshipFormState();

  @override
  List<Object?> get props => [];
}

class RelationshipFormInitial extends RelationshipFormState {
  const RelationshipFormInitial();
}

class RelationshipFormLoading extends RelationshipFormState {
  const RelationshipFormLoading();
}

class RelationshipFormSuccess extends RelationshipFormState {
  final String message;

  const RelationshipFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RelationshipFormError extends RelationshipFormState {
  final String message;

  const RelationshipFormError(this.message);

  @override
  List<Object?> get props => [message];
}
