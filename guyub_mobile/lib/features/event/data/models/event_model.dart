import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';
part 'event_model.g.dart';

@JsonSerializable()
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    super.familyId,
    required super.startDate,
    super.endDate,
    required super.location,
    super.locationAddress,
    required super.participantIds,
    super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.pendingSync,
    super.syncedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Convert model to domain entity
  @override
  Event toEntity() => Event(
    id: id,
    title: title,
    description: description,
    type: type, // Parse from string to enum
    status: status, // Parse from string to enum
    familyId: familyId,
    startDate: startDate,
    endDate: endDate,
    location: location,
    locationAddress: locationAddress,
    participantIds: participantIds,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
    pendingSync: pendingSync,
    syncedAt: syncedAt,
  );

  /// Convert domain entity to model
  static EventModel fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      type: event.type, // Enum to string
      status: event.status, // Enum to string
      familyId: event.familyId,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      locationAddress: event.locationAddress,
      participantIds: event.participantIds,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      pendingSync: event.pendingSync,
      syncedAt: event.syncedAt,
    );
  }
}
