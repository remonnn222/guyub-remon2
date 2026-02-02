import 'package:equatable/equatable.dart';

/// Family Entity
/// Represents a family tree group
class Family extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? origin;
  final String? inviteCode;
  final bool isPublic;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // For offline support
  final bool pendingSync;
  final DateTime? syncedAt;

  const Family({
    required this.id,
    required this.name,
    this.description,
    this.origin,
    this.inviteCode,
    this.isPublic = false,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.pendingSync = false,
    this.syncedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        origin,
        inviteCode,
        isPublic,
        createdBy,
        createdAt,
        updatedAt,
        pendingSync,
        syncedAt,
      ];

  Family copyWith({
    int? id,
    String? name,
    String? description,
    String? origin,
    String? inviteCode,
    bool? isPublic,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
    DateTime? syncedAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      inviteCode: inviteCode ?? this.inviteCode,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

/// Family Tree Data
/// Contains all data needed to render a family tree
class FamilyTreeData extends Equatable {
  final Family family;
  final List<Person> persons;
  final List<Relationship> relationships;
  final List<TreePosition> positions;

  const FamilyTreeData({
    required this.family,
    required this.persons,
    required this.relationships,
    required this.positions,
  });

  /// Get root persons (those without parents in the tree)
  List<Person> get rootPersons {
    final childIds = relationships
        .where((r) => r.type == RelationshipType.parent)
        .map((r) => r.relatedPersonId)
        .toSet();

    return persons.where((p) => !childIds.contains(p.id)).toList();
  }

  /// Get person by ID
  Person? getPersonById(int id) {
    try {
      return persons.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get position for person
  TreePosition? getPositionForPerson(int personId) {
    try {
      return positions.firstWhere((p) => p.personId == personId);
    } catch (_) {
      return null;
    }
  }

  /// Get children of a person
  List<Person> getChildren(int personId) {
    final childIds = relationships
        .where((r) => r.type == RelationshipType.parent && r.personId == personId)
        .map((r) => r.relatedPersonId)
        .toSet();

    return persons.where((p) => childIds.contains(p.id)).toList();
  }

  /// Get parents of a person
  List<Person> getParents(int personId) {
    final parentIds = relationships
        .where((r) => r.type == RelationshipType.parent && r.relatedPersonId == personId)
        .map((r) => r.personId)
        .toSet();

    return persons.where((p) => parentIds.contains(p.id)).toList();
  }

  /// Get spouse of a person
  Person? getSpouse(int personId) {
    final spouseRel = relationships.where((r) =>
        r.type == RelationshipType.spouse &&
        (r.personId == personId || r.relatedPersonId == personId)).firstOrNull;

    if (spouseRel == null) return null;

    final spouseId = spouseRel.personId == personId
        ? spouseRel.relatedPersonId
        : spouseRel.personId;

    return getPersonById(spouseId);
  }

  /// Get siblings of a person
  List<Person> getSiblings(int personId) {
    final siblingIds = relationships
        .where((r) => r.type == RelationshipType.sibling &&
            (r.personId == personId || r.relatedPersonId == personId))
        .expand((r) => [r.personId, r.relatedPersonId])
        .where((id) => id != personId)
        .toSet();

    return persons.where((p) => siblingIds.contains(p.id)).toList();
  }

  @override
  List<Object?> get props => [family, persons, relationships, positions];
}

/// Person Entity
class Person extends Equatable {
  final int id;
  final int familyId;
  final String firstName;
  final String? lastName;
  final String? gender;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? birthPlace;
  final String? deathPlace;
  final String? occupation;
  final String? bio;
  final String? avatarUrl;
  final int generationLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // For offline support
  final bool pendingSync;
  final DateTime? syncedAt;

  const Person({
    required this.id,
    required this.familyId,
    required this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.deathDate,
    this.birthPlace,
    this.deathPlace,
    this.occupation,
    this.bio,
    this.avatarUrl,
    this.generationLevel = 0,
    this.createdAt,
    this.updatedAt,
    this.pendingSync = false,
    this.syncedAt,
  });

  /// Get full name
  String get fullName => lastName != null ? '$firstName $lastName' : firstName;

  /// Get initials for avatar
  String get initials {
    if (lastName != null && lastName!.isNotEmpty) {
      return '${firstName[0]}${lastName![0]}'.toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  /// Check if person is alive
  bool get isAlive => deathDate == null;

  /// Get age (or age at death)
  int? get age {
    if (birthDate == null) return null;
    final endDate = deathDate ?? DateTime.now();
    int age = endDate.year - birthDate!.year;
    if (endDate.month < birthDate!.month ||
        (endDate.month == birthDate!.month && endDate.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Get gender display text
  String get genderDisplay {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return 'Lainnya';
    }
  }

  @override
  List<Object?> get props => [
        id,
        familyId,
        firstName,
        lastName,
        gender,
        birthDate,
        deathDate,
        birthPlace,
        deathPlace,
        occupation,
        bio,
        avatarUrl,
        generationLevel,
        createdAt,
        updatedAt,
        pendingSync,
        syncedAt,
      ];

  Person copyWith({
    int? id,
    int? familyId,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? birthDate,
    DateTime? deathDate,
    String? birthPlace,
    String? deathPlace,
    String? occupation,
    String? bio,
    String? avatarUrl,
    int? generationLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
    DateTime? syncedAt,
  }) {
    return Person(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      birthPlace: birthPlace ?? this.birthPlace,
      deathPlace: deathPlace ?? this.deathPlace,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      generationLevel: generationLevel ?? this.generationLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

/// Relationship Type Enum
enum RelationshipType {
  parent,
  child,
  spouse,
  sibling,
}

/// Marriage Status Enum
enum MarriageStatus {
  married,
  divorced,
  widowed,
  engaged,
}

/// Relationship Entity
class Relationship extends Equatable {
  final int id;
  final int personId;
  final int relatedPersonId;
  final RelationshipType type;
  final MarriageStatus? marriageStatus;
  final DateTime? marriageDate;
  final DateTime? divorceDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // For offline support
  final bool pendingSync;
  final DateTime? syncedAt;

  const Relationship({
    required this.id,
    required this.personId,
    required this.relatedPersonId,
    required this.type,
    this.marriageStatus,
    this.marriageDate,
    this.divorceDate,
    this.createdAt,
    this.updatedAt,
    this.pendingSync = false,
    this.syncedAt,
  });

  @override
  List<Object?> get props => [
        id,
        personId,
        relatedPersonId,
        type,
        marriageStatus,
        marriageDate,
        divorceDate,
        createdAt,
        updatedAt,
        pendingSync,
        syncedAt,
      ];

  Relationship copyWith({
    int? id,
    int? personId,
    int? relatedPersonId,
    RelationshipType? type,
    MarriageStatus? marriageStatus,
    DateTime? marriageDate,
    DateTime? divorceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
    DateTime? syncedAt,
  }) {
    return Relationship(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      relatedPersonId: relatedPersonId ?? this.relatedPersonId,
      type: type ?? this.type,
      marriageStatus: marriageStatus ?? this.marriageStatus,
      marriageDate: marriageDate ?? this.marriageDate,
      divorceDate: divorceDate ?? this.divorceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

/// Tree Position Entity
/// Stores x, y coordinates for each person in the tree visualization
class TreePosition extends Equatable {
  final int id;
  final int personId;
  final int familyId;
  final double x;
  final double y;
  final int level;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TreePosition({
    required this.id,
    required this.personId,
    required this.familyId,
    required this.x,
    required this.y,
    this.level = 0,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        personId,
        familyId,
        x,
        y,
        level,
        order,
        createdAt,
        updatedAt,
      ];

  TreePosition copyWith({
    int? id,
    int? personId,
    int? familyId,
    double? x,
    double? y,
    int? level,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TreePosition(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      familyId: familyId ?? this.familyId,
      x: x ?? this.x,
      y: y ?? this.y,
      level: level ?? this.level,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
