import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/event_repository.dart';
import '../event_state.dart';

/// Event Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return sl<EventRepository>();
});

/// Event List Notifier
class EventListNotifier extends Notifier<EventListState> {
  @override
  EventListState build() {
    Future.microtask(() => loadEvents());
    return const EventListInitial();
  }

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  Future<void> loadEvents({String? filter}) async {
    state = const EventListLoading();

    final result = await _repository.getEvents(filter: filter);

    result.fold(
      (failure) => state = EventListError(failure.message),
      (events) => state = EventListLoaded(events: events),
    );
  }

  Future<void> refresh() async {
    await loadEvents();
  }

  Future<void> createEvent(CreateEventParams params) async {
    final currentState = state;
    state = const EventListLoading();

    final result = await _repository.createEvent(params);

    result.fold((failure) => state = EventListError(failure.message), (
      newEvent,
    ) {
      if (currentState is EventListLoaded) {
        state = EventListLoaded(events: [newEvent, ...currentState.events]);
      } else {
        loadEvents();
      }
    });
  }

  Future<void> deleteEvent(int id) async {
    final currentState = state;

    final result = await _repository.deleteEvent(id);

    result.fold((failure) => state = EventListError(failure.message), (_) {
      if (currentState is EventListLoaded) {
        state = EventListLoaded(
          events: currentState.events.where((e) => e.id != id).toList(),
        );
      }
    });
  }
}

/// Event List Provider
final eventListProvider = NotifierProvider<EventListNotifier, EventListState>(
  () {
    return EventListNotifier();
  },
);

/// Event Detail Notifier
class EventDetailNotifier extends Notifier<EventDetailState> {
  int? _currentEventId;

  @override
  EventDetailState build() => const EventDetailInitial();

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  Future<void> loadEvent(int eventId) async {
    _currentEventId = eventId;
    state = const EventDetailLoading();

    final result = await _repository.getEventById(eventId);

    result.fold(
      (failure) => state = EventDetailError(failure.message),
      (event) => state = EventDetailLoaded(event: event),
    );
  }

  Future<void> refresh() async {
    if (_currentEventId != null) {
      await loadEvent(_currentEventId!);
    }
  }

  Future<void> approveEvent() async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      state = const EventDetailLoading();

      final result = await _repository.approveEvent(current.event.id);

      result.fold(
        (failure) => state = EventDetailError(failure.message),
        (updatedEvent) => state = EventDetailLoaded(event: updatedEvent),
      );
    }
  }

  Future<void> rejectEvent() async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      state = const EventDetailLoading();

      final result = await _repository.rejectEvent(current.event.id);

      result.fold(
        (failure) => state = EventDetailError(failure.message),
        (updatedEvent) => state = EventDetailLoaded(event: updatedEvent),
      );
    }
  }
}

/// Event Detail Provider
final eventDetailProvider =
    NotifierProvider<EventDetailNotifier, EventDetailState>(() {
      return EventDetailNotifier();
    });

/// Event Form Notifier
class EventFormNotifier extends Notifier<EventFormState> {
  @override
  EventFormState build() => const EventFormInitial();

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  Future<void> createEvent(CreateEventParams params) async {
    state = const EventFormLoading();

    final result = await _repository.createEvent(params);

    result.fold(
      (failure) => state = EventFormError(failure.message),
      (event) => state = EventFormSuccess(
        event: event,
        message: 'Event berhasil dibuat',
      ),
    );
  }

  Future<void> updateEvent(int id, UpdateEventParams params) async {
    state = const EventFormLoading();

    final result = await _repository.updateEvent(id, params);

    result.fold(
      (failure) => state = EventFormError(failure.message),
      (event) => state = EventFormSuccess(
        event: event,
        message: 'Event berhasil diupdate',
      ),
    );
  }

  void reset() {
    state = const EventFormInitial();
  }
}

/// Event Form Provider
final eventFormProvider = NotifierProvider<EventFormNotifier, EventFormState>(
  () {
    return EventFormNotifier();
  },
);

/// Event Sync Notifier
class EventSyncNotifier extends Notifier<EventSyncState> {
  @override
  EventSyncState build() => const EventSyncInitial();

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  Future<void> sync() async {
    state = const EventSyncLoading();

    final result = await _repository.syncOfflineData();

    result.fold(
      (failure) => state = EventSyncError(failure.message),
      (_) => state = const EventSyncSuccess('Sync berhasil'),
    );
  }
}

/// Event Sync Provider
final eventSyncProvider = NotifierProvider<EventSyncNotifier, EventSyncState>(
  () {
    return EventSyncNotifier();
  },
);

/// Pending sync count provider
final eventPendingSyncCountProvider = StreamProvider<int>((ref) async* {
  final repository = ref.read(eventRepositoryProvider);
  while (true) {
    final result = await repository.getPendingSyncCount();
    yield result.fold((_) => 0, (count) => count);
    await Future.delayed(const Duration(seconds: 3));
  }
});
