// Event State Classes (freezed-free, manual union like family)

/// Event List States
sealed class EventListState {}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {}

class EventListLoaded extends EventListState {
  final List<Event> events;
  const EventListLoaded({required this.events});
}

class EventListError extends EventListState {
  final String message;
  const EventListError(this.message);
}

/// Event Detail States
sealed class EventDetailState {}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final Event event;
  const EventDetailLoaded({required this.event});
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError(this.message);
}

/// Event Form States (create/edit)
sealed class EventFormState {}

class EventFormInitial extends EventFormState {}

class EventFormLoading extends EventFormState {}

class EventFormSuccess extends EventFormState {
  final Event? event;
  final String message;
  const EventFormSuccess({this.event, required this.message});
}

class EventFormError extends EventFormState {
  final String message;
  const EventFormError(this.message);
}

/// Event Sync States
sealed class EventSyncState {}

class EventSyncInitial extends EventSyncState {}

class EventSyncLoading extends EventSyncState {}

class EventSyncSuccess extends EventSyncState {
  final String message;
  const EventSyncSuccess(this.message);
}

class EventSyncError extends EventSyncState {
  final String message;
  const EventSyncError(this.message);
}
