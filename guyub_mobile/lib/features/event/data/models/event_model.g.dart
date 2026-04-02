// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  type: json['type'] as String,
  status: json['status'] as String,
  familyId: (json['family_id'] as num?)?.toInt(),
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String?,
  location: json['location'] as String,
  locationAddress: json['location_address'] as String?,
  participantIds: json['participant_ids'] as List<dynamic>,
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'family_id': instance.familyId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'location': instance.location,
      'location_address': instance.locationAddress,
      'participant_ids': instance.participantIds,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
