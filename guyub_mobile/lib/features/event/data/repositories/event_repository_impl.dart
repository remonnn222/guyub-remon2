import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_database.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../datasources/event_local_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    String? filter,
    int? familyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Offline-first: local data first
      final localEvents = await localDataSource.getEvents(
        filter: filter,
        familyId: familyId,
      );

      // Background sync if connected
      if (await networkInfo.isConnected) {
        _syncEventsInBackground(filter, familyId);
      }

      return Right(localEvents.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Fallback to remote if local fails
      if (await networkInfo.isConnected) {
        try {
          final remoteEvents = await remoteDataSource.getEvents(
            filter: filter,
            familyId: familyId,
            page: page,
            limit: limit,
          );
          await localDataSource.saveEvents(remoteEvents);
          return Right(remoteEvents.map((m) => m.toEntity()).toList());
        } catch (remoteError) {
          return Left(_handleError(remoteError));
        }
      }
      return Left(_handleError(e));
    }
  }

  Future<void> _syncEventsInBackground(String? filter, int? familyId) async {
    try {
      final remoteEvents = await remoteDataSource.getEvents(
        filter: filter,
        familyId: familyId,
        page: 1,
        limit: 100, // Load more for sync
      );
      await localDataSource.saveEvents(remoteEvents);
    } catch (_) {
      // Silent fail
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(int id) async {
    try {
      final localEvent = await localDataSource.getEventById(id);
      if (localEvent != null) {
        if (await networkInfo.isConnected) {
          _syncEventInBackground(id);
        }
        return Right(localEvent.toEntity());
      }

      if (await networkInfo.isConnected) {
        final remoteEvent = await remoteDataSource.getEventById(id);
        await localDataSource.saveEvent(remoteEvent);
        return Right(remoteEvent.toEntity());
      }

      return const Left(CacheFailure(message: 'Event not found offline'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<void> _syncEventInBackground(int id) async {
    try {
      final remoteEvent = await remoteDataSource.getEventById(id);
      await localDataSource.saveEvent(remoteEvent);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Event>> createEvent(CreateEventParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteEvent = await remoteDataSource.createEvent(params);
        await localDataSource.saveEvent(remoteEvent);
        return Right(remoteEvent.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      // Queue offline
      await localDataSource.addToSyncQueue(
        SyncQueueItem(
          action: SyncAction.create,
          entityType: SyncEntityType.event,
          payload: params.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      return const Left(
        NetworkFailure(message: 'Offline: Event queued for sync'),
      );
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(
    int id,
    UpdateEventParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteEvent = await remoteDataSource.updateEvent(id, params);
        await localDataSource.saveEvent(remoteEvent);
        return Right(remoteEvent.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(
        SyncQueueItem(
          action: SyncAction.update,
          entityType: SyncEntityType.event,
          entityId: id,
          payload: params.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      return const Left(
        NetworkFailure(message: 'Offline: Event queued for sync'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteEvent(id);
        await localDataSource.deleteEvent(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(
        SyncQueueItem(
          action: SyncAction.delete,
          entityType: SyncEntityType.event,
          entityId: id,
          payload: {'id': id},
          createdAt: DateTime.now(),
        ),
      );
      await localDataSource.deleteEvent(id);
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, Event>> approveEvent(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedEvent = await remoteDataSource.approveEvent(id);
        await localDataSource.saveEvent(updatedEvent);
        return Right(updatedEvent.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    }
    return const Left(
      NetworkFailure(message: 'Internet required to approve event'),
    );
  }

  @override
  Future<Either<Failure, Event>> rejectEvent(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedEvent = await remoteDataSource.rejectEvent(id);
        await localDataSource.saveEvent(updatedEvent);
        return Right(updatedEvent.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    }
    return const Left(
      NetworkFailure(message: 'Internet required to reject event'),
    );
  }

  @override
  Future<Either<Failure, void>> syncOfflineData() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet'));
    }

    try {
      final pendingCount = await localDataSource.getPendingSyncCount();
      if (pendingCount == 0) return const Right(null);

      final pendingItems = await localDataSource.getPendingSyncItems();
      for (final item in pendingItems) {
        if (item.retryCount >= 3) continue;

        final delay = Duration(seconds: math.pow(2, item.retryCount).toInt());
        if (delay > Duration.zero) await Future.delayed(delay);

        try {
          await _processSyncItem(item);
          await localDataSource.markSyncCompleted(item.id!);
        } catch (e) {
          await localDataSource.markSyncFailed(item.id!, e.toString());
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<void> _processSyncItem(SyncQueueItem item) async {
    switch (item.entityType) {
      case SyncEntityType.event:
        switch (item.action) {
          case SyncAction.create:
            await remoteDataSource.createEvent(
              CreateEventParams.fromJson(item.payload),
            );
            break;
          case SyncAction.update:
            await remoteDataSource.updateEvent(
              item.entityId!,
              UpdateEventParams.fromJson(item.payload),
            );
            break;
          case SyncAction.delete:
            await remoteDataSource.deleteEvent(item.entityId!);
            break;
        }
        break;
      default:
        // Handle other entity types if needed
        break;
    }
  }

  @override
  Future<Either<Failure, int>> getPendingSyncCount() async {
    try {
      final count = await localDataSource.getPendingSyncCount();
      return Right(count);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Failure _handleError(dynamic e) {
    if (e is AppException) {
      return switch (e) {
        ServerException() => ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
        UnauthorizedException() => AuthFailure(message: e.message),
        ValidationException() => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
        _ => ServerFailure(message: e.message),
      };
    }
    return ServerFailure(message: e.toString());
  }
}
