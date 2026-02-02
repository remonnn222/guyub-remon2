import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/family.dart';

/// Family Repository Interface
abstract class FamilyRepository {
  /// Get all families for current user
  Future<Either<Failure, List<Family>>> getFamilies();

  /// Get family by ID
  Future<Either<Failure, Family>> getFamilyById(int id);

  /// Get family tree data (family + persons + relationships + positions)
  Future<Either<Failure, FamilyTreeData>> getFamilyTree(int familyId);

  /// Create a new family
  Future<Either<Failure, Family>> createFamily(CreateFamilyParams params);

  /// Update family
  Future<Either<Failure, Family>> updateFamily(int id, UpdateFamilyParams params);

  /// Delete family
  Future<Either<Failure, void>> deleteFamily(int id);

  /// Join family by invite code
  Future<Either<Failure, Family>> joinFamily(String inviteCode);

  /// Get all persons in a family
  Future<Either<Failure, List<Person>>> getPersons(int familyId);

  /// Get person by ID
  Future<Either<Failure, Person>> getPersonById(int id);

  /// Create a new person
  Future<Either<Failure, Person>> createPerson(CreatePersonParams params);

  /// Update person
  Future<Either<Failure, Person>> updatePerson(int id, UpdatePersonParams params);

  /// Delete person
  Future<Either<Failure, void>> deletePerson(int id);

  /// Create relationship between persons
  Future<Either<Failure, Relationship>> createRelationship(CreateRelationshipParams params);

  /// Delete relationship
  Future<Either<Failure, void>> deleteRelationship(int id);

  /// Update tree positions (batch)
  Future<Either<Failure, void>> updateTreePositions(int familyId, List<TreePosition> positions);

  /// Sync offline data
  Future<Either<Failure, void>> syncOfflineData();
}

/// Create Family Parameters
class CreateFamilyParams {
  final String name;
  final String? description;
  final String? origin;
  final bool isPublic;

  const CreateFamilyParams({
    required this.name,
    this.description,
    this.origin,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        if (origin != null) 'origin': origin,
        'is_public': isPublic,
      };
}

/// Update Family Parameters
class UpdateFamilyParams {
  final String? name;
  final String? description;
  final String? origin;
  final bool? isPublic;

  const UpdateFamilyParams({
    this.name,
    this.description,
    this.origin,
    this.isPublic,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (origin != null) map['origin'] = origin;
    if (isPublic != null) map['is_public'] = isPublic;
    return map;
  }
}

/// Create Person Parameters
class CreatePersonParams {
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
  final int generationLevel;

  const CreatePersonParams({
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
    this.generationLevel = 0,
  });

  Map<String, dynamic> toJson() => {
        'family_id': familyId,
        'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T')[0],
        if (deathDate != null) 'death_date': deathDate!.toIso8601String().split('T')[0],
        if (birthPlace != null) 'birth_place': birthPlace,
        if (deathPlace != null) 'death_place': deathPlace,
        if (occupation != null) 'occupation': occupation,
        if (bio != null) 'bio': bio,
        'generation_level': generationLevel,
      };
}

/// Update Person Parameters
class UpdatePersonParams {
  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? birthPlace;
  final String? deathPlace;
  final String? occupation;
  final String? bio;
  final int? generationLevel;

  const UpdatePersonParams({
    this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.deathDate,
    this.birthPlace,
    this.deathPlace,
    this.occupation,
    this.bio,
    this.generationLevel,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (gender != null) map['gender'] = gender;
    if (birthDate != null) map['birth_date'] = birthDate!.toIso8601String().split('T')[0];
    if (deathDate != null) map['death_date'] = deathDate!.toIso8601String().split('T')[0];
    if (birthPlace != null) map['birth_place'] = birthPlace;
    if (deathPlace != null) map['death_place'] = deathPlace;
    if (occupation != null) map['occupation'] = occupation;
    if (bio != null) map['bio'] = bio;
    if (generationLevel != null) map['generation_level'] = generationLevel;
    return map;
  }
}

/// Create Relationship Parameters
class CreateRelationshipParams {
  final int personId;
  final int relatedPersonId;
  final RelationshipType type;
  final MarriageStatus? marriageStatus;
  final DateTime? marriageDate;

  const CreateRelationshipParams({
    required this.personId,
    required this.relatedPersonId,
    required this.type,
    this.marriageStatus,
    this.marriageDate,
  });

  Map<String, dynamic> toJson() => {
        'person_id': personId,
        'related_person_id': relatedPersonId,
        'type': type.name,
        if (marriageStatus != null) 'marriage_status': marriageStatus!.name,
        if (marriageDate != null) 'marriage_date': marriageDate!.toIso8601String().split('T')[0],
      };
}
