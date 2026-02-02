import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_database.dart';
import '../../domain/entities/family.dart';
import '../../domain/repositories/family_repository.dart';
import '../datasources/family_remote_datasource.dart';
import '../datasources/family_local_datasource.dart';
import '../models/family_model.dart';

/// Family Repository Implementation with Offline-First Pattern
class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource remoteDataSource;
  final FamilyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FamilyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Family>>> getFamilies() async {
    try {
      // Always return local data first (offline-first)
      final localFamilies = await localDataSource.getFamilies();

      // Sync in background if connected
      if (await networkInfo.isConnected) {
        _syncFamiliesInBackground();
      }

      return Right(localFamilies.map((m) => m.toEntity()).toList());
    } catch (e) {
      // If local fails, try remote
      if (await networkInfo.isConnected) {
        try {
          final remoteFamilies = await remoteDataSource.getFamilies();
          await localDataSource.saveFamilies(remoteFamilies);
          return Right(remoteFamilies.map((m) => m.toEntity()).toList());
        } catch (e) {
          return Left(_handleError(e));
        }
      }
      return Left(_handleError(e));
    }
  }

  Future<void> _syncFamiliesInBackground() async {
    try {
      final remoteFamilies = await remoteDataSource.getFamilies();
      await localDataSource.saveFamilies(remoteFamilies);
    } catch (_) {
      // Silently fail background sync
    }
  }

  @override
  Future<Either<Failure, Family>> getFamilyById(int id) async {
    try {
      // Try local first
      final localFamily = await localDataSource.getFamilyById(id);

      if (localFamily != null) {
        // Sync in background
        if (await networkInfo.isConnected) {
          _syncFamilyInBackground(id);
        }
        return Right(localFamily.toEntity());
      }

      // If not in local, fetch from remote
      if (await networkInfo.isConnected) {
        final remoteFamily = await remoteDataSource.getFamilyById(id);
        await localDataSource.saveFamily(remoteFamily);
        return Right(remoteFamily.toEntity());
      }

      return const Left(CacheFailure(message: 'Family not found offline'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<void> _syncFamilyInBackground(int id) async {
    try {
      final remoteFamily = await remoteDataSource.getFamilyById(id);
      await localDataSource.saveFamily(remoteFamily);
    } catch (_) {
      // Silently fail
    }
  }

  @override
  Future<Either<Failure, FamilyTreeData>> getFamilyTree(int familyId) async {
    try {
      // Try local first
      final localTree = await localDataSource.getFamilyTree(familyId);

      if (localTree != null) {
        // Sync in background
        if (await networkInfo.isConnected) {
          _syncFamilyTreeInBackground(familyId);
        }
        return Right(localTree.toEntity());
      }

      // If not in local, fetch from remote
      if (await networkInfo.isConnected) {
        final remoteTree = await remoteDataSource.getFamilyTree(familyId);
        await localDataSource.syncFamilyTree(remoteTree);
        return Right(remoteTree.toEntity());
      }

      return const Left(CacheFailure(message: 'Family tree not found offline'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<void> _syncFamilyTreeInBackground(int familyId) async {
    try {
      final remoteTree = await remoteDataSource.getFamilyTree(familyId);
      await localDataSource.syncFamilyTree(remoteTree);
    } catch (_) {
      // Silently fail
    }
  }

  @override
  Future<Either<Failure, Family>> createFamily(CreateFamilyParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFamily = await remoteDataSource.createFamily(params);
        await localDataSource.saveFamily(remoteFamily);
        return Right(remoteFamily.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      // Queue for later sync
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.create,
        entityType: SyncEntityType.family,
        payload: params.toJson(),
        createdAt: DateTime.now(),
      ));
      return const Left(NetworkFailure(message: 'Offline: Family will be created when online'));
    }
  }

  @override
  Future<Either<Failure, Family>> updateFamily(int id, UpdateFamilyParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFamily = await remoteDataSource.updateFamily(id, params);
        await localDataSource.saveFamily(remoteFamily);
        return Right(remoteFamily.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      // Queue for later sync
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.update,
        entityType: SyncEntityType.family,
        entityId: id,
        payload: params.toJson(),
        createdAt: DateTime.now(),
      ));
      return const Left(NetworkFailure(message: 'Offline: Family will be updated when online'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFamily(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFamily(id);
        await localDataSource.deleteFamily(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      // Queue for later sync
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.delete,
        entityType: SyncEntityType.family,
        entityId: id,
        payload: {'id': id},
        createdAt: DateTime.now(),
      ));
      await localDataSource.deleteFamily(id);
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, Family>> joinFamily(String inviteCode) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Internet required to join family'));
    }

    try {
      final family = await remoteDataSource.joinFamily(inviteCode);
      await localDataSource.saveFamily(family);
      return Right(family.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Person>>> getPersons(int familyId) async {
    try {
      final localPersons = await localDataSource.getPersons(familyId);

      if (localPersons.isNotEmpty) {
        if (await networkInfo.isConnected) {
          _syncPersonsInBackground(familyId);
        }
        return Right(localPersons.map((m) => m.toEntity()).toList());
      }

      if (await networkInfo.isConnected) {
        final remotePersons = await remoteDataSource.getPersons(familyId);
        await localDataSource.savePersons(remotePersons);
        return Right(remotePersons.map((m) => m.toEntity()).toList());
      }

      return const Right([]);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<void> _syncPersonsInBackground(int familyId) async {
    try {
      final remotePersons = await remoteDataSource.getPersons(familyId);
      await localDataSource.savePersons(remotePersons);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Person>> getPersonById(int id) async {
    try {
      final localPerson = await localDataSource.getPersonById(id);

      if (localPerson != null) {
        return Right(localPerson.toEntity());
      }

      if (await networkInfo.isConnected) {
        final remotePerson = await remoteDataSource.getPersonById(id);
        await localDataSource.savePerson(remotePerson);
        return Right(remotePerson.toEntity());
      }

      return const Left(CacheFailure(message: 'Person not found offline'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Person>> createPerson(CreatePersonParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePerson = await remoteDataSource.createPerson(params);
        await localDataSource.savePerson(remotePerson);
        return Right(remotePerson.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.create,
        entityType: SyncEntityType.person,
        payload: params.toJson(),
        createdAt: DateTime.now(),
      ));
      return const Left(NetworkFailure(message: 'Offline: Person will be created when online'));
    }
  }

  @override
  Future<Either<Failure, Person>> updatePerson(int id, UpdatePersonParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePerson = await remoteDataSource.updatePerson(id, params);
        await localDataSource.savePerson(remotePerson);
        return Right(remotePerson.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.update,
        entityType: SyncEntityType.person,
        entityId: id,
        payload: params.toJson(),
        createdAt: DateTime.now(),
      ));
      return const Left(NetworkFailure(message: 'Offline: Person will be updated when online'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePerson(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePerson(id);
        await localDataSource.deletePerson(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.delete,
        entityType: SyncEntityType.person,
        entityId: id,
        payload: {'id': id},
        createdAt: DateTime.now(),
      ));
      await localDataSource.deletePerson(id);
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, Relationship>> createRelationship(CreateRelationshipParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRel = await remoteDataSource.createRelationship(params);
        await localDataSource.saveRelationship(remoteRel);
        return Right(remoteRel.toEntity());
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.create,
        entityType: SyncEntityType.relationship,
        payload: params.toJson(),
        createdAt: DateTime.now(),
      ));
      return const Left(NetworkFailure(message: 'Offline: Relationship will be created when online'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRelationship(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteRelationship(id);
        await localDataSource.deleteRelationship(id);
        return const Right(null);
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.delete,
        entityType: SyncEntityType.relationship,
        entityId: id,
        payload: {'id': id},
        createdAt: DateTime.now(),
      ));
      await localDataSource.deleteRelationship(id);
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateTreePositions(int familyId, List<TreePosition> positions) async {
    final positionModels = positions.map((p) => TreePositionModel.fromEntity(p)).toList();

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateTreePositions(familyId, positionModels);
        await localDataSource.saveTreePositions(positionModels);
        return const Right(null);
      } catch (e) {
        return Left(_handleError(e));
      }
    } else {
      await localDataSource.saveTreePositions(positionModels);
      await localDataSource.addToSyncQueue(SyncQueueItem(
        action: SyncAction.update,
        entityType: SyncEntityType.treePosition,
        entityId: familyId,
        payload: {'family_id': familyId, 'positions': positions.map((p) => {
          'person_id': p.personId,
          'x': p.x,
          'y': p.y,
          'level': p.level,
          'order': p.order,
        }).toList()},
        createdAt: DateTime.now(),
      ));
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineData() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final pendingItems = await localDataSource.getPendingSyncItems();

      for (final item in pendingItems) {
        try {
          await _processSyncItem(item);
          await localDataSource.markSyncCompleted(item.id!);
        } catch (e) {
          await localDataSource.markSyncFailed(item.id!, e.toString());
        }
      }

      await localDataSource.clearSyncQueue();
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<void> _processSyncItem(SyncQueueItem item) async {
    switch (item.entityType) {
      case SyncEntityType.family:
        await _syncFamily(item);
        break;
      case SyncEntityType.person:
        await _syncPerson(item);
        break;
      case SyncEntityType.relationship:
        await _syncRelationship(item);
        break;
      case SyncEntityType.treePosition:
        await _syncTreePositions(item);
        break;
    }
  }

  Future<void> _syncFamily(SyncQueueItem item) async {
    switch (item.action) {
      case SyncAction.create:
        await remoteDataSource.createFamily(CreateFamilyParams(
          name: item.payload['name'] as String,
          description: item.payload['description'] as String?,
          origin: item.payload['origin'] as String?,
          isPublic: item.payload['is_public'] as bool? ?? false,
        ));
        break;
      case SyncAction.update:
        await remoteDataSource.updateFamily(
          item.entityId!,
          UpdateFamilyParams(
            name: item.payload['name'] as String?,
            description: item.payload['description'] as String?,
            origin: item.payload['origin'] as String?,
            isPublic: item.payload['is_public'] as bool?,
          ),
        );
        break;
      case SyncAction.delete:
        await remoteDataSource.deleteFamily(item.entityId!);
        break;
    }
  }

  Future<void> _syncPerson(SyncQueueItem item) async {
    switch (item.action) {
      case SyncAction.create:
        await remoteDataSource.createPerson(CreatePersonParams(
          familyId: item.payload['family_id'] as int,
          firstName: item.payload['first_name'] as String,
          lastName: item.payload['last_name'] as String?,
          gender: item.payload['gender'] as String?,
          generationLevel: item.payload['generation_level'] as int? ?? 0,
        ));
        break;
      case SyncAction.update:
        await remoteDataSource.updatePerson(
          item.entityId!,
          UpdatePersonParams(
            firstName: item.payload['first_name'] as String?,
            lastName: item.payload['last_name'] as String?,
            gender: item.payload['gender'] as String?,
          ),
        );
        break;
      case SyncAction.delete:
        await remoteDataSource.deletePerson(item.entityId!);
        break;
    }
  }

  Future<void> _syncRelationship(SyncQueueItem item) async {
    switch (item.action) {
      case SyncAction.create:
        final typeStr = item.payload['type'] as String;
        await remoteDataSource.createRelationship(CreateRelationshipParams(
          personId: item.payload['person_id'] as int,
          relatedPersonId: item.payload['related_person_id'] as int,
          type: RelationshipType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => RelationshipType.parent,
          ),
        ));
        break;
      case SyncAction.update:
        // Relationships don't support update, only delete and create
        break;
      case SyncAction.delete:
        await remoteDataSource.deleteRelationship(item.entityId!);
        break;
    }
  }

  Future<void> _syncTreePositions(SyncQueueItem item) async {
    final familyId = item.payload['family_id'] as int;
    final positionsList = item.payload['positions'] as List;
    final positions = positionsList.map((p) => TreePositionModel(
      id: 0,
      personId: p['person_id'] as int,
      familyId: familyId,
      x: (p['x'] as num).toDouble(),
      y: (p['y'] as num).toDouble(),
      level: p['level'] as int? ?? 0,
      order: p['order'] as int? ?? 0,
    )).toList();

    await remoteDataSource.updateTreePositions(familyId, positions);
  }

  Failure _handleError(dynamic e) {
    if (e is ServerException) {
      return ServerFailure(message: e.message);
    }
    if (e is UnauthorizedException) {
      return const UnauthorizedFailure(message: 'Unauthorized');
    }
    if (e is NetworkException) {
      return NetworkFailure(message: e.message);
    }
    if (e is CacheException) {
      return CacheFailure(message: e.message);
    }
    return ServerFailure(message: e.toString());
  }
}
