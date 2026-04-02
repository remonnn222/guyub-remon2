import '../../../../core/storage/local_database.dart';
import '../models/event_model.dart';

import 'package:sqflite/sqflite.dart';

abstract class EventLocalDataSource {
  Future<List<EventModel>> getEvents({String? filter, int? familyId});
  Future<EventModel?> getEventById(int id);
  Future<void> saveEvents(List<EventModel> events);
  Future<void> saveEvent(EventModel event);
  Future<void> deleteEvent(int id);
  Future<int> getPendingSyncCount();
  Future<void> syncOfflineData();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  @override
  Future<List<EventModel>> getEvents({String? filter, int? familyId}) async {
    final db = await LocalDatabase.database;

    String whereClause = 'pending_sync = 0';
    List<String> whereArgs = [];

    if (filter != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(filter);
    }
    if (familyId != null) {
      whereClause += ' AND family_id = ?';
      whereArgs.add(familyId.toString());
    }

    final List<Map> maps = await db.query(
      'events',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => EventModel.fromJson(map)).toList();
  }

  @override
  Future<EventModel?> getEventById(int id) async {
    final db = await LocalDatabase.database;

    final List<Map> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return EventModel.fromJson(maps.first);
  }

  @override
  Future<void> saveEvents(List<EventModel> events) async {
    final db = await LocalDatabase.database;
    await db.transaction((txn) async {
      for (final event in events) {
        await _saveEventTxn(txn, event.toJson());
      }
    });
  }

  Future<void> _saveEventTxn(
    Transaction txn,
    Map<String, dynamic> eventJson,
  ) async {
    await txn.insert(
      'events',
      eventJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await txn.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    final db = await LocalDatabase.database;
    await db.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
  Future<void> syncOfflineData() {
    // Handled by EventRepository syncOfflineData()
    // Local datasource only provides raw data access
    return Future.value();
  }
}
