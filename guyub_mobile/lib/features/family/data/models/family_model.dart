import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/family.dart';

part 'family_model.g.dart';

@JsonSerializable()
class FamilyModel {
  final int id;
  final String name;
  final String? description;
  final String? origin;
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const FamilyModel({
    required this.id,
    required this.name,
    this.description,
    this.origin,
    this.inviteCode,
    this.isPublic = false,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyModelToJson(this);

  Family toEntity() => Family(
        id: id,
        name: name,
        description: description,
        origin: origin,
        inviteCode: inviteCode,
        isPublic: isPublic,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory FamilyModel.fromEntity(Family entity) => FamilyModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        origin: entity.origin,
        inviteCode: entity.inviteCode,
        isPublic: entity.isPublic,
        createdBy: entity.createdBy,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

@JsonSerializable()
class PersonModel {
  final int id;
  @JsonKey(name: 'family_id')
  final int familyId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? gender;
  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;
  @JsonKey(name: 'death_date')
  final DateTime? deathDate;
  @JsonKey(name: 'birth_place')
  final String? birthPlace;
  @JsonKey(name: 'death_place')
  final String? deathPlace;
  final String? occupation;
  final String? bio;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'generation_level')
  final int generationLevel;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const PersonModel({
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
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) =>
      _$PersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonModelToJson(this);

  Person toEntity() => Person(
        id: id,
        familyId: familyId,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birthDate: birthDate,
        deathDate: deathDate,
        birthPlace: birthPlace,
        deathPlace: deathPlace,
        occupation: occupation,
        bio: bio,
        avatarUrl: avatarUrl,
        generationLevel: generationLevel,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory PersonModel.fromEntity(Person entity) => PersonModel(
        id: entity.id,
        familyId: entity.familyId,
        firstName: entity.firstName,
        lastName: entity.lastName,
        gender: entity.gender,
        birthDate: entity.birthDate,
        deathDate: entity.deathDate,
        birthPlace: entity.birthPlace,
        deathPlace: entity.deathPlace,
        occupation: entity.occupation,
        bio: entity.bio,
        avatarUrl: entity.avatarUrl,
        generationLevel: entity.generationLevel,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

@JsonSerializable()
class RelationshipModel {
  final int id;
  @JsonKey(name: 'person_id')
  final int personId;
  @JsonKey(name: 'related_person_id')
  final int relatedPersonId;
  final String type;
  @JsonKey(name: 'marriage_status')
  final String? marriageStatus;
  @JsonKey(name: 'marriage_date')
  final DateTime? marriageDate;
  @JsonKey(name: 'divorce_date')
  final DateTime? divorceDate;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const RelationshipModel({
    required this.id,
    required this.personId,
    required this.relatedPersonId,
    required this.type,
    this.marriageStatus,
    this.marriageDate,
    this.divorceDate,
    this.createdAt,
    this.updatedAt,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$RelationshipModelFromJson(json);

  Map<String, dynamic> toJson() => _$RelationshipModelToJson(this);

  Relationship toEntity() => Relationship(
        id: id,
        personId: personId,
        relatedPersonId: relatedPersonId,
        type: _parseRelationshipType(type),
        marriageStatus: marriageStatus != null
            ? _parseMarriageStatus(marriageStatus!)
            : null,
        marriageDate: marriageDate,
        divorceDate: divorceDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static RelationshipType _parseRelationshipType(String type) {
    switch (type.toLowerCase()) {
      case 'parent':
        return RelationshipType.parent;
      case 'child':
        return RelationshipType.child;
      case 'spouse':
        return RelationshipType.spouse;
      case 'sibling':
        return RelationshipType.sibling;
      default:
        return RelationshipType.parent;
    }
  }

  static MarriageStatus _parseMarriageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'married':
        return MarriageStatus.married;
      case 'divorced':
        return MarriageStatus.divorced;
      case 'widowed':
        return MarriageStatus.widowed;
      case 'engaged':
        return MarriageStatus.engaged;
      default:
        return MarriageStatus.married;
    }
  }

  factory RelationshipModel.fromEntity(Relationship entity) => RelationshipModel(
        id: entity.id,
        personId: entity.personId,
        relatedPersonId: entity.relatedPersonId,
        type: entity.type.name,
        marriageStatus: entity.marriageStatus?.name,
        marriageDate: entity.marriageDate,
        divorceDate: entity.divorceDate,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

@JsonSerializable()
class TreePositionModel {
  final int id;
  @JsonKey(name: 'person_id')
  final int personId;
  @JsonKey(name: 'family_id')
  final int familyId;
  final double x;
  final double y;
  final int level;
  final int order;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const TreePositionModel({
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

  factory TreePositionModel.fromJson(Map<String, dynamic> json) =>
      _$TreePositionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TreePositionModelToJson(this);

  TreePosition toEntity() => TreePosition(
        id: id,
        personId: personId,
        familyId: familyId,
        x: x,
        y: y,
        level: level,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory TreePositionModel.fromEntity(TreePosition entity) => TreePositionModel(
        id: entity.id,
        personId: entity.personId,
        familyId: entity.familyId,
        x: entity.x,
        y: entity.y,
        level: entity.level,
        order: entity.order,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

/// Family Tree Response from API
@JsonSerializable()
class FamilyTreeResponse {
  final FamilyModel family;
  final List<PersonModel> persons;
  final List<RelationshipModel> relationships;
  final List<TreePositionModel> positions;

  const FamilyTreeResponse({
    required this.family,
    required this.persons,
    required this.relationships,
    required this.positions,
  });

  factory FamilyTreeResponse.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyTreeResponseToJson(this);

  FamilyTreeData toEntity() => FamilyTreeData(
        family: family.toEntity(),
        persons: persons.map((p) => p.toEntity()).toList(),
        relationships: relationships.map((r) => r.toEntity()).toList(),
        positions: positions.map((p) => p.toEntity()).toList(),
      );
}
