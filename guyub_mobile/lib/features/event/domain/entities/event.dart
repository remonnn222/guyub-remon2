import 'package:equatable/equatable.dart';

/// Event Status Enum
enum EventStatus {
  draft('draft', 'Draft'),
  pending('pending', 'Menunggu Persetujuan'),
  approved('approved', 'Disetujui'),
  scheduled('scheduled', 'Terjadwal'),
  ongoing('ongoing', 'Berlangsung'),
  finished('finished', 'Selesai'),
  cancelled('cancelled', 'Dibatalkan'),
  rejected('rejected', 'Ditolak');

  const EventStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  /// Status badge color class name (for AppColors usage in UI)
  String get badgeColorClass => switch (this) {
    EventStatus.draft => 'grey',
    EventStatus.pending => 'orange',
    EventStatus.approved || EventStatus.scheduled => 'green',
    EventStatus.ongoing => 'blue',
    EventStatus.finished => 'purple',
    EventStatus.cancelled || EventStatus.rejected => 'red',
  };
}

/// Event Type Enum
enum EventType {
  family_gathering('family_gathering', 'Kumpul Keluarga'),
  reunion('reunion', 'Reuni Keluarga'),
  celebration('celebration', 'Perayaan'),
  birthday('birthday', 'Ulang Tahun'),
  marriage('marriage', 'Pernikahan'),
  funeral('funeral', 'Kematian'),
  other('other', 'Lainnya');

  const EventType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Event Entity
class Event extends Equatable {
  final int id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final int? familyId;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String? locationAddress;
  final List<int> participantIds;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Offline support
  final bool pendingSync;
  final DateTime? syncedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.familyId,
    required this.startDate,
    this.endDate,
    required this.location,
    this.locationAddress,
    required this.participantIds,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.pendingSync = false,
    this.syncedAt,
  });

  /// Is upcoming event
  bool get isUpcoming =>
      startDate.isAfter(DateTime.now()) && status == EventStatus.scheduled;

  /// Is ongoing event
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) &&
      (endDate == null || DateTime.now().isBefore(endDate!)) &&
      status == EventStatus.ongoing;

  /// Is past event
  bool get isPast =>
      endDate != null && endDate!.isBefore(DateTime.now()) ||
      status == EventStatus.finished;

  /// Status badge text
  String get statusDisplay => status.displayName;

  /// Type display text
  String get typeDisplay => type.displayName;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    status,
    familyId,
    startDate,
    endDate,
    location,
    locationAddress,
    participantIds,
    createdBy,
    createdAt,
    updatedAt,
    pendingSync,
    syncedAt,
  ];

  Event copyWith({
    int? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    int? familyId,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? locationAddress,
    List<int>? participantIds,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendingSync,
    DateTime? syncedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      familyId: familyId ?? this.familyId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
