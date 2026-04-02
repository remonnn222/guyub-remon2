// Event State Classes (freezed-free, manual union like family)
import '../domain/entities/event.dart';

/// Event List States
sealed class EventListState {
  const EventListState();
}

class EventListInitial extends EventListState {
  const EventListInitial();
}

class EventListLoading extends EventListState {
  const EventListLoading();
}

class EventListLoaded extends EventListState {
  final List<Event> events;
  const EventListLoaded({required this.events});
}

class EventListError extends EventListState {
  final String message;
  const EventListError(this.message);
}

/// Event Detail States
sealed class EventDetailState {
  const EventDetailState();
}

class EventDetailInitial extends EventDetailState {
  const EventDetailInitial();
}

class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();
}

class EventDetailLoaded extends EventDetailState {
  final Event event;
  const EventDetailLoaded({required this.event});
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError(this.message);
}

/// Event Form States (create/edit)
sealed class EventFormState {
  const EventFormState();
}

class EventFormInitial extends EventFormState {
  const EventFormInitial();
}

class EventFormLoading extends EventFormState {
  const EventFormLoading();
}

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
sealed class EventSyncState {
  const EventSyncState();
}

class EventSyncInitial extends EventSyncState {
  const EventSyncInitial();
}

class EventSyncLoading extends EventSyncState {
  const EventSyncLoading();
}

class EventSyncSuccess extends EventSyncState {
  final String message;
  const EventSyncSuccess(this.message);
}

class EventSyncError extends EventSyncState {
  final String message;
  const EventSyncError(this.message);
}

/// Extension for pattern matching on EventListState
extension EventListStateX on EventListState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Event> events) loaded,
    required T Function(String message) error,
  }) {
    return switch (this) {
      EventListInitial() => initial(),
      EventListLoading() => loading(),
      EventListLoaded(events: final e) => loaded(e),
      EventListError(message: final m) => error(m),
    };
  }
}

/// Extension for pattern matching on EventDetailState
extension EventDetailStateX on EventDetailState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(Event event) loaded,
    required T Function(String message) error,
  }) {
    return switch (this) {
      EventDetailInitial() => initial(),
      EventDetailLoading() => loading(),
      EventDetailLoaded(event: final e) => loaded(e),
      EventDetailError(message: final m) => error(m),
    };
  }
}
