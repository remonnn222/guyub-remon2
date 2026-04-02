import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/local_database.dart';
import '../models/family_model.dart';

/// Family Local Data Source Interface
abstract class FamilyLocalDataSource {
  /// Get all families from local storage
  Future<List<FamilyModel>> getFamilies();

  /// Get family by ID
  Future<FamilyModel?> getFamilyById(int id);

  /// Get family tree data from local storage
  Future<FamilyTreeResponse?> getFamilyTree(int familyId);

  /// Save family to local storage
  Future<void> saveFamily(FamilyModel family);

  /// Save multiple families
  Future<void> saveFamilies(List<FamilyModel> families);

  /// Delete family from local storage
  Future<void> deleteFamily(int id);

  /// Get all persons in a family
  Future<List<PersonModel>> getPersons(int familyId);

  /// Get person by ID
  Future<PersonModel?> getPersonById(int id);

  /// Save person to local storage
  Future<void> savePerson(PersonModel person);

  /// Save multiple persons
  Future<void> savePersons(List<PersonModel> persons);

  /// Delete person from local storage
  Future<void> deletePerson(int id);

  /// Get relationships for a family
  Future<List<RelationshipModel>> getRelationships(int familyId);

  /// Save relationship
  Future<void> saveRelationship(RelationshipModel relationship);

  /// Save multiple relationships
  Future<void> saveRelationships(List<RelationshipModel> relationships);

  /// Delete relationship
  Future<void> deleteRelationship(int id);

  /// Get tree positions for a family
  Future<List<TreePositionModel>> getTreePositions(int familyId);

  /// Save tree position
  Future<void> saveTreePosition(TreePositionModel position);

  /// Save multiple tree positions
  Future<void> saveTreePositions(List<TreePositionModel> positions);

  /// Delete tree positions for a family
  Future<void> deleteTreePositions(int familyId);

  /// Add to sync queue
  Future<void> addToSyncQueue(SyncQueueItem item);

  /// Get pending sync items
  Future<List<SyncQueueItem>> getPendingSyncItems();

  /// Get pending sync item count (pending + retryable failed)
  Future<int> getPendingSyncItemCount();

  /// Mark sync item as completed
  Future<void> markSyncCompleted(int id);

  /// Mark sync item as failed
  Future<void> markSyncFailed(int id, String errorMessage);

  /// Clear sync queue
  Future<void> clearSyncQueue();

  /// Sync complete family tree data (upsert all)
  Future<void> syncFamilyTree(FamilyTreeResponse treeData);
}

/// Family Local Data Source Implementation
class FamilyLocalDataSourceImpl implements FamilyLocalDataSource {
  @override
  Future<List<FamilyModel>> getFamilies() async {
    final db = await LocalDatabase.database;
    final maps = await db.query('families', orderBy: 'updated_at DESC');
    return maps.map((m) => _familyFromMap(m)).toList();
  }

  @override
  Future<FamilyModel?> getFamilyById(int id) async {
    final db = await LocalDatabase.database;
    final maps = await db.query('families', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _familyFromMap(maps.first);
  }

  @override
  Future<FamilyTreeResponse?> getFamilyTree(int familyId) async {
    final family = await getFamilyById(familyId);
    if (family == null) return null;

    final persons = await getPersons(familyId);
    final relationships = await getRelationships(familyId);
    final positions = await getTreePositions(familyId);

    return FamilyTreeResponse(
      family: family,
      persons: persons,
      relationships: relationships,
      positions: positions,
    );
  }

  @override
  Future<void> saveFamily(FamilyModel family) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'families',
      _familyToMap(family),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveFamilies(List<FamilyModel> families) async {
    final db = await LocalDatabase.database;
    final batch = db.batch();
    for (final family in families) {
      batch.insert(
        'families',
        _familyToMap(family),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteFamily(int id) async {
    final db = await LocalDatabase.database;
    await db.delete('families', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<PersonModel>> getPersons(int familyId) async {
    final db = await LocalDatabase.database;
    final maps = await db.query(
      'persons',
      where: 'family_id = ?',
      whereArgs: [familyId],
      orderBy: 'generation_level ASC, first_name ASC',
    );
    return maps.map((m) => _personFromMap(m)).toList();
  }

  @override
  Future<PersonModel?> getPersonById(int id) async {
    final db = await LocalDatabase.database;
    final maps = await db.query('persons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _personFromMap(maps.first);
  }

  @override
  Future<void> savePerson(PersonModel person) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'persons',
      _personToMap(person),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> savePersons(List<PersonModel> persons) async {
    final db = await LocalDatabase.database;
    final batch = db.batch();
    for (final person in persons) {
      batch.insert(
        'persons',
        _personToMap(person),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deletePerson(int id) async {
    final db = await LocalDatabase.database;
    await db.delete('persons', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<RelationshipModel>> getRelationships(int familyId) async {
    final db = await LocalDatabase.database;
    // Get all persons in family first, then get their relationships
    final personIds = await db.query(
      'persons',
      columns: ['id'],
      where: 'family_id = ?',
      whereArgs: [familyId],
    );

    if (personIds.isEmpty) return [];

    final ids = personIds.map((m) => m['id'] as int).toList();
    final placeholders = List.filled(ids.length, '?').join(',');

    final maps = await db.query(
      'relationships',
      where:
          'person_id IN ($placeholders) OR related_person_id IN ($placeholders)',
      whereArgs: [...ids, ...ids],
    );
    return maps.map((m) => _relationshipFromMap(m)).toList();
  }

  @override
  Future<void> saveRelationship(RelationshipModel relationship) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'relationships',
      _relationshipToMap(relationship),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveRelationships(List<RelationshipModel> relationships) async {
    final db = await LocalDatabase.database;
    final batch = db.batch();
    for (final relationship in relationships) {
      batch.insert(
        'relationships',
        _relationshipToMap(relationship),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteRelationship(int id) async {
    final db = await LocalDatabase.database;
    await db.delete('relationships', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TreePositionModel>> getTreePositions(int familyId) async {
    final db = await LocalDatabase.database;
    final maps = await db.query(
      'tree_positions',
      where: 'family_id = ?',
      whereArgs: [familyId],
    );
    return maps.map((m) => _treePositionFromMap(m)).toList();
  }

  @override
  Future<void> saveTreePosition(TreePositionModel position) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'tree_positions',
      _treePositionToMap(position),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveTreePositions(List<TreePositionModel> positions) async {
    final db = await LocalDatabase.database;
    final batch = db.batch();
    for (final position in positions) {
      batch.insert(
        'tree_positions',
        _treePositionToMap(position),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteTreePositions(int familyId) async {
    final db = await LocalDatabase.database;
    await db.delete(
      'tree_positions',
      where: 'family_id = ?',
      whereArgs: [familyId],
    );
  }

  @override
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final db = await LocalDatabase.database;
    await db.insert('sync_queue', {
      'action': item.action.name,
      'entity_type': item.entityType.name,
      'entity_id': item.entityId,
      'payload': jsonEncode(item.payload),
      'created_at': item.createdAt.toIso8601String(),
      'status': item.status,
      'error_message': item.errorMessage,
      'retry_count': item.retryCount,
    });
  }

  @override
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    final db = await LocalDatabase.database;
    final maps = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
    return maps
        .map(
          (m) => SyncQueueItem(
            id: m['id'] as int,
            action: SyncAction.values.firstWhere((e) => e.name == m['action']),
            entityType: SyncEntityType.values.firstWhere(
              (e) => e.name == m['entity_type'],
            ),
            entityId: m['entity_id'] as int?,
            payload: jsonDecode(m['payload'] as String),
            createdAt: DateTime.parse(m['created_at'] as String),
            status: m['status'] as String,
            errorMessage: m['error_message'] as String?,
            retryCount: m['retry_count'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> markSyncCompleted(int id) async {
    final db = await LocalDatabase.database;
    await db.update(
      'sync_queue',
      {'status': 'completed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getPendingSyncItemCount() async {
    final db = await LocalDatabase.database;
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM sync_queue
      WHERE status = 'pending'
      OR (status = 'failed' AND retry_count < 3)
    ''');
    return Sqflite.firstIntValue(countResult) ?? 0;
  }

  @override
  Future<void> markSyncFailed(int id, String errorMessage) async {
    final db = await LocalDatabase.database;
    await db.rawUpdate(
      '''
      UPDATE sync_queue
      SET
        retry_count = retry_count + 1,
        status = CASE
          WHEN retry_count + 1 >= 3 THEN 'failed'
          ELSE 'pending'
        END,
        error_message = ?
      WHERE id = ?
      ''',
      [errorMessage, id],
    );
  }

  @override
  Future<void> clearSyncQueue() async {
    final db = await LocalDatabase.database;
    await db.delete(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['completed'],
    );
  }

  @override
  Future<void> syncFamilyTree(FamilyTreeResponse treeData) async {
    final db = await LocalDatabase.database;

    await db.transaction((txn) async {
      // Save family
      await txn.insert(
        'families',
        _familyToMap(treeData.family),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Clear old data for this family
      final familyId = treeData.family.id;
      await txn.delete(
        'tree_positions',
        where: 'family_id = ?',
        whereArgs: [familyId],
      );

      // Get existing persons
      final existingPersonIds = (await txn.query(
        'persons',
        columns: ['id'],
        where: 'family_id = ?',
        whereArgs: [familyId],
      )).map((m) => m['id'] as int).toSet();

      // Delete relationships for persons that will be removed
      final newPersonIds = treeData.persons.map((p) => p.id).toSet();
      final toRemove = existingPersonIds.difference(newPersonIds);
      if (toRemove.isNotEmpty) {
        final placeholders = List.filled(toRemove.length, '?').join(',');
        await txn.delete(
          'relationships',
          where:
              'person_id IN ($placeholders) OR related_person_id IN ($placeholders)',
          whereArgs: [...toRemove, ...toRemove],
        );
        await txn.delete(
          'persons',
          where: 'id IN ($placeholders)',
          whereArgs: toRemove.toList(),
        );
      }

      // Save persons
      for (final person in treeData.persons) {
        await txn.insert(
          'persons',
          _personToMap(person),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Save relationships
      for (final relationship in treeData.relationships) {
        await txn.insert(
          'relationships',
          _relationshipToMap(relationship),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Save positions
      for (final position in treeData.positions) {
        await txn.insert(
          'tree_positions',
          _treePositionToMap(position),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Mappers
  Map<String, dynamic> _familyToMap(FamilyModel family) => {
    'id': family.id,
    'name': family.name,
    'description': family.description,
    'origin': family.origin,
    'invite_code': family.inviteCode,
    'is_public': family.isPublic ? 1 : 0,
    'created_by': family.createdBy,
    'created_at': family.createdAt?.toIso8601String(),
    'updated_at': family.updatedAt?.toIso8601String(),
    'pending_sync': 0,
    'synced_at': DateTime.now().toIso8601String(),
  };

  FamilyModel _familyFromMap(Map<String, dynamic> map) => FamilyModel(
    id: map['id'] as int,
    name: map['name'] as String,
    description: map['description'] as String?,
    origin: map['origin'] as String?,
    inviteCode: map['invite_code'] as String?,
    isPublic: (map['is_public'] as int) == 1,
    createdBy: map['created_by'] as int?,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> _personToMap(PersonModel person) => {
    'id': person.id,
    'family_id': person.familyId,
    'first_name': person.firstName,
    'last_name': person.lastName,
    'gender': person.gender,
    'birth_date': person.birthDate?.toIso8601String(),
    'death_date': person.deathDate?.toIso8601String(),
    'birth_place': person.birthPlace,
    'death_place': person.deathPlace,
    'occupation': person.occupation,
    'bio': person.bio,
    'avatar_url': person.avatarUrl,
    'generation_level': person.generationLevel,
    'created_at': person.createdAt?.toIso8601String(),
    'updated_at': person.updatedAt?.toIso8601String(),
    'pending_sync': 0,
    'synced_at': DateTime.now().toIso8601String(),
  };

  PersonModel _personFromMap(Map<String, dynamic> map) => PersonModel(
    id: map['id'] as int,
    familyId: map['family_id'] as int,
    firstName: map['first_name'] as String,
    lastName: map['last_name'] as String?,
    gender: map['gender'] as String?,
    birthDate: map['birth_date'] != null
        ? DateTime.parse(map['birth_date'] as String)
        : null,
    deathDate: map['death_date'] != null
        ? DateTime.parse(map['death_date'] as String)
        : null,
    birthPlace: map['birth_place'] as String?,
    deathPlace: map['death_place'] as String?,
    occupation: map['occupation'] as String?,
    bio: map['bio'] as String?,
    avatarUrl: map['avatar_url'] as String?,
    generationLevel: map['generation_level'] as int? ?? 0,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> _relationshipToMap(RelationshipModel rel) => {
    'id': rel.id,
    'person_id': rel.personId,
    'related_person_id': rel.relatedPersonId,
    'type': rel.type,
    'marriage_status': rel.marriageStatus,
    'marriage_date': rel.marriageDate?.toIso8601String(),
    'divorce_date': rel.divorceDate?.toIso8601String(),
    'created_at': rel.createdAt?.toIso8601String(),
    'updated_at': rel.updatedAt?.toIso8601String(),
    'pending_sync': 0,
    'synced_at': DateTime.now().toIso8601String(),
  };

  RelationshipModel _relationshipFromMap(Map<String, dynamic> map) =>
      RelationshipModel(
        id: map['id'] as int,
        personId: map['person_id'] as int,
        relatedPersonId: map['related_person_id'] as int,
        type: map['type'] as String,
        marriageStatus: map['marriage_status'] as String?,
        marriageDate: map['marriage_date'] != null
            ? DateTime.parse(map['marriage_date'] as String)
            : null,
        divorceDate: map['divorce_date'] != null
            ? DateTime.parse(map['divorce_date'] as String)
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> _treePositionToMap(TreePositionModel pos) => {
    'id': pos.id,
    'person_id': pos.personId,
    'family_id': pos.familyId,
    'x': pos.x,
    'y': pos.y,
    'level': pos.level,
    'sort_order': pos.order,
    'created_at': pos.createdAt?.toIso8601String(),
    'updated_at': pos.updatedAt?.toIso8601String(),
  };

  TreePositionModel _treePositionFromMap(Map<String, dynamic> map) =>
      TreePositionModel(
        id: map['id'] as int,
        personId: map['person_id'] as int,
        familyId: map['family_id'] as int,
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        level: map['level'] as int? ?? 0,
        order: map['sort_order'] as int? ?? 0,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );
}
