import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';

part 'event_model.g.dart';

/// Event Model for JSON serialization
@JsonSerializable()
class EventModel {
  final int id;
  final String title;
  final String? description;
  final String type; // raw string from API
  final String status; // raw string from API
  @JsonKey(name: 'family_id')
  final int? familyId;
  @JsonKey(name: 'start_date')
  final String startDate; // ISO string
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String location;
  @JsonKey(name: 'location_address')
  final String? locationAddress;
  @JsonKey(name: 'participant_ids')
  final List<dynamic> participantIds; // raw list from API
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.familyId,
    required this.startDate,
    this.endDate,
    required this.location,
    this.locationAddress,
    required this.participantIds,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Parse string to EventType enum
  static EventType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'family_gathering':
        return EventType.family_gathering;
      case 'reunion':
        return EventType.reunion;
      case 'celebration':
        return EventType.celebration;
      case 'birthday':
        return EventType.birthday;
      case 'marriage':
        return EventType.marriage;
      case 'funeral':
        return EventType.funeral;
      case 'other':
        return EventType.other;
      default:
        return EventType.other;
    }
  }

  /// Parse string to EventStatus enum
  static EventStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return EventStatus.draft;
      case 'pending':
        return EventStatus.pending;
      case 'approved':
        return EventStatus.approved;
      case 'scheduled':
        return EventStatus.scheduled;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'finished':
        return EventStatus.finished;
      case 'cancelled':
        return EventStatus.cancelled;
      case 'rejected':
        return EventStatus.rejected;
      default:
        return EventStatus.draft;
    }
  }

  /// Convert model to domain entity
  Event toEntity() => Event(
    id: id,
    title: title,
    description: description ?? '',
    type: _parseType(type),
    status: _parseStatus(status),
    familyId: familyId,
    startDate: DateTime.parse(startDate),
    endDate: endDate != null ? DateTime.parse(endDate!) : null,
    location: location,
    locationAddress: locationAddress,
    participantIds: participantIds.map((e) => e as int).toList(),
    createdBy: createdBy,
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
    updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : DateTime.now(),
    pendingSync: false,
    syncedAt: DateTime.now(),
  );

  /// Convert domain entity to model
  static EventModel fromEntity(Event event) => EventModel(
    id: event.id,
    title: event.title,
    description: event.description.isEmpty ? null : event.description,
    type: event.type.value,
    status: event.status.value,
    familyId: event.familyId,
    startDate: event.startDate.toIso8601String(),
    endDate: event.endDate?.toIso8601String(),
    location: event.location,
    locationAddress: event.locationAddress,
    participantIds: event.participantIds,
    createdBy: event.createdBy,
    createdAt: event.createdAt.toIso8601String(),
    updatedAt: event.updatedAt.toIso8601String(),
  );

  /// Convert model to SQLite map (snake_case keys)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'status': status,
    'family_id': familyId,
    'start_date': startDate,
    'end_date': endDate,
    'location': location,
    'location_address': locationAddress,
    'participant_ids': jsonEncode(participantIds),
    'created_by': createdBy,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'pending_sync': 0,
    'synced_at': DateTime.now().toIso8601String(),
  };

  /// Create model from SQLite map
  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
    id: map['id'] as int,
    title: map['title'] as String,
    description: map['description'] as String?,
    type: map['type'] as String,
    status: map['status'] as String,
    familyId: map['family_id'] as int?,
    startDate: map['start_date'] as String,
    endDate: map['end_date'] as String?,
    location: map['location'] as String,
    locationAddress: map['location_address'] as String?,
    participantIds: map['participant_ids'] != null
        ? jsonDecode(map['participant_ids'] as String)
        : [],
    createdBy: map['created_by'] as int?,
    createdAt: map['created_at'] as String?,
    updatedAt: map['updated_at'] as String?,
  );
}
