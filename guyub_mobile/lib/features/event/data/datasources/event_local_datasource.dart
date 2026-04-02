import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/local_database.dart';
import '../models/event_model.dart';

/// Event Local Data Source Interface
abstract class EventLocalDataSource {
  /// Get all events from local storage
  Future<List<EventModel>> getEvents({String? filter, int? familyId});

  /// Get event by ID
  Future<EventModel?> getEventById(int id);

  /// Save event to local storage
  Future<void> saveEvent(EventModel event);

  /// Save multiple events
  Future<void> saveEvents(List<EventModel> events);

  /// Delete event from local storage
  Future<void> deleteEvent(int id);

  /// Get pending sync count
  Future<int> getPendingSyncCount();

  /// Add item to sync queue
  Future<void> addToSyncQueue(SyncQueueItem item);

  /// Get pending sync items
  Future<List<SyncQueueItem>> getPendingSyncItems();

  /// Mark sync item as completed
  Future<void> markSyncCompleted(int id);

  /// Mark sync item as failed
  Future<void> markSyncFailed(int id, String errorMessage);

  /// Get pending sync item count
  Future<int> getPendingSyncItemCount();
}

/// Event Local Data Source Implementation
class EventLocalDataSourceImpl implements EventLocalDataSource {
  @override
  Future<List<EventModel>> getEvents({String? filter, int? familyId}) async {
    final db = await LocalDatabase.database;

    String? whereClause;
    List<Object?>? whereArgs;

    if (filter != null && filter.isNotEmpty) {
      whereClause = 'status = ?';
      whereArgs = [filter];
    }
    if (familyId != null) {
      whereClause = whereClause != null
          ? '$whereClause AND family_id = ?'
          : 'family_id = ?';
      whereArgs = whereArgs != null ? [...whereArgs, familyId] : [familyId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => EventModel.fromMap(map)).toList();
  }

  @override
  Future<EventModel?> getEventById(int id) async {
    final db = await LocalDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return EventModel.fromMap(maps.first);
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveEvents(List<EventModel> events) async {
    final db = await LocalDatabase.database;
    final batch = db.batch();
    for (final event in events) {
      batch.insert(
        'events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteEvent(int id) async {
    final db = await LocalDatabase.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getPendingSyncCount() async {
    final db = await LocalDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM events WHERE pending_sync = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
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
      where: 'status = ? AND entity_type = ?',
      whereArgs: ['pending', 'event'],
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
  Future<int> getPendingSyncItemCount() async {
    final db = await LocalDatabase.database;
    final countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM sync_queue
      WHERE entity_type = ? AND (status = 'pending' OR (status = 'failed' AND retry_count < 3))
    ''',
      ['event'],
    );
    return Sqflite.firstIntValue(countResult) ?? 0;
  }
}
