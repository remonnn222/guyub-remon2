// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyModel _$FamilyModelFromJson(Map<String, dynamic> json) => FamilyModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  origin: json['origin'] as String?,
  inviteCode: json['invite_code'] as String?,
  isPublic: json['is_public'] as bool? ?? false,
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FamilyModelToJson(FamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'origin': instance.origin,
      'invite_code': instance.inviteCode,
      'is_public': instance.isPublic,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

PersonModel _$PersonModelFromJson(Map<String, dynamic> json) => PersonModel(
  id: (json['id'] as num).toInt(),
  familyId: (json['family_id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String?,
  gender: json['gender'] as String?,
  birthDate: json['birth_date'] == null
      ? null
      : DateTime.parse(json['birth_date'] as String),
  deathDate: json['death_date'] == null
      ? null
      : DateTime.parse(json['death_date'] as String),
  birthPlace: json['birth_place'] as String?,
  deathPlace: json['death_place'] as String?,
  occupation: json['occupation'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  generationLevel: (json['generation_level'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PersonModelToJson(PersonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'family_id': instance.familyId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'gender': instance.gender,
      'birth_date': instance.birthDate?.toIso8601String(),
      'death_date': instance.deathDate?.toIso8601String(),
      'birth_place': instance.birthPlace,
      'death_place': instance.deathPlace,
      'occupation': instance.occupation,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'generation_level': instance.generationLevel,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

RelationshipModel _$RelationshipModelFromJson(Map<String, dynamic> json) =>
    RelationshipModel(
      id: (json['id'] as num).toInt(),
      personId: (json['person_id'] as num).toInt(),
      relatedPersonId: (json['related_person_id'] as num).toInt(),
      type: json['type'] as String,
      marriageStatus: json['marriage_status'] as String?,
      marriageDate: json['marriage_date'] == null
          ? null
          : DateTime.parse(json['marriage_date'] as String),
      divorceDate: json['divorce_date'] == null
          ? null
          : DateTime.parse(json['divorce_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RelationshipModelToJson(RelationshipModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person_id': instance.personId,
      'related_person_id': instance.relatedPersonId,
      'type': instance.type,
      'marriage_status': instance.marriageStatus,
      'marriage_date': instance.marriageDate?.toIso8601String(),
      'divorce_date': instance.divorceDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

TreePositionModel _$TreePositionModelFromJson(Map<String, dynamic> json) =>
    TreePositionModel(
      id: (json['id'] as num).toInt(),
      personId: (json['person_id'] as num).toInt(),
      familyId: (json['family_id'] as num).toInt(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      level: (json['level'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TreePositionModelToJson(TreePositionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person_id': instance.personId,
      'family_id': instance.familyId,
      'x': instance.x,
      'y': instance.y,
      'level': instance.level,
      'order': instance.order,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

FamilyTreeResponse _$FamilyTreeResponseFromJson(Map<String, dynamic> json) =>
    FamilyTreeResponse(
      family: FamilyModel.fromJson(json['family'] as Map<String, dynamic>),
      persons: (json['persons'] as List<dynamic>)
          .map((e) => PersonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      relationships: (json['relationships'] as List<dynamic>)
          .map((e) => RelationshipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      positions: (json['positions'] as List<dynamic>)
          .map((e) => TreePositionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FamilyTreeResponseToJson(FamilyTreeResponse instance) =>
    <String, dynamic>{
      'family': instance.family,
      'persons': instance.persons,
      'relationships': instance.relationships,
      'positions': instance.positions,
    };
