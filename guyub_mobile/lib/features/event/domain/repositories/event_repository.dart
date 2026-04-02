import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';

abstract class EventRepository {
  /// Get all events with optional filter
  Future<Either<Failure, List<Event>>> getEvents({
    String? filter,
    int? familyId,
    int page = 1,
    int limit = 20,
  });

  /// Get single event by ID
  Future<Either<Failure, Event>> getEventById(int id);

  /// Create new event
  Future<Either<Failure, Event>> createEvent(CreateEventParams params);

  /// Update event
  Future<Either<Failure, Event>> updateEvent(int id, UpdateEventParams params);

  /// Delete event
  Future<Either<Failure, void>> deleteEvent(int id);

  /// Approve event
  Future<Either<Failure, Event>> approveEvent(int id);

  /// Reject event
  Future<Either<Failure, Event>> rejectEvent(int id);

  /// Sync offline data
  Future<Either<Failure, void>> syncOfflineData();

  /// Get pending sync count
  Future<Either<Failure, int>> getPendingSyncCount();
}

/// Params classes
class CreateEventParams {
  final String title;
  final String description;
  final String type; // event_type value
  final int? familyId;
  final String startDate;
  final String? endDate;
  final String location;
  final String? locationAddress;
  final List<int> participantIds;

  const CreateEventParams({
    required this.title,
    required this.description,
    required this.type,
    this.familyId,
    required this.startDate,
    this.endDate,
    required this.location,
    this.locationAddress,
    required this.participantIds,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    if (familyId != null) 'family_id': familyId,
    'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
    'location': location,
    if (locationAddress != null) 'location_address': locationAddress,
    'participant_ids': participantIds,
  };
}

class UpdateEventParams {
  final String? title;
  final String? description;
  final String? type;
  final int? familyId;
  final String? startDate;
  final String? endDate;
  final String? location;
  final String? locationAddress;
  final List<int>? participantIds;

  const UpdateEventParams({
    this.title,
    this.description,
    this.type,
    this.familyId,
    this.startDate,
    this.endDate,
    this.location,
    this.locationAddress,
    this.participantIds,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (type != null) 'type': type,
    if (familyId != null) 'family_id': familyId,
    if (startDate != null) 'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
    if (location != null) 'location': location,
    if (locationAddress != null) 'location_address': locationAddress,
    if (participantIds != null) 'participant_ids': participantIds,
  };
}
