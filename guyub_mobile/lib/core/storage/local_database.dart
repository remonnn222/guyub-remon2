import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local Database Helper for Offline Storage
class LocalDatabase {
  static const String _databaseName = 'guyub_offline.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  /// Get database instance (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  static Future<void> _onCreate(Database db, int version) async {
    // Families table
    await db.execute('''
      CREATE TABLE families (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        origin TEXT,
        invite_code TEXT,
        is_public INTEGER NOT NULL DEFAULT 0,
        created_by INTEGER,
        created_at TEXT,
        updated_at TEXT,
        pending_sync INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT
      )
    ''');

    // Persons table
    await db.execute('''
      CREATE TABLE persons (
        id INTEGER PRIMARY KEY,
        family_id INTEGER NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT,
        gender TEXT,
        birth_date TEXT,
        death_date TEXT,
        birth_place TEXT,
        death_place TEXT,
        occupation TEXT,
        bio TEXT,
        avatar_url TEXT,
        generation_level INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        pending_sync INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    // Relationships table
    await db.execute('''
      CREATE TABLE relationships (
        id INTEGER PRIMARY KEY,
        person_id INTEGER NOT NULL,
        related_person_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        marriage_status TEXT,
        marriage_date TEXT,
        divorce_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        pending_sync INTEGER NOT NULL DEFAULT 0,
        synced_at TEXT,
        FOREIGN KEY (person_id) REFERENCES persons (id) ON DELETE CASCADE,
        FOREIGN KEY (related_person_id) REFERENCES persons (id) ON DELETE CASCADE
      )
    ''');

    // Tree positions table
    await db.execute('''
      CREATE TABLE tree_positions (
        id INTEGER PRIMARY KEY,
        person_id INTEGER NOT NULL,
        family_id INTEGER NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        level INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (person_id) REFERENCES persons (id) ON DELETE CASCADE,
        FOREIGN KEY (family_id) REFERENCES families (id) ON DELETE CASCADE
      )
    ''');

    // Sync queue table for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        error_message TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_persons_family ON persons (family_id)');
    await db.execute('CREATE INDEX idx_relationships_person ON relationships (person_id)');
    await db.execute('CREATE INDEX idx_relationships_related ON relationships (related_person_id)');
    await db.execute('CREATE INDEX idx_tree_positions_person ON tree_positions (person_id)');
    await db.execute('CREATE INDEX idx_tree_positions_family ON tree_positions (family_id)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue (status)');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all data (useful for logout)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('sync_queue');
    await db.delete('tree_positions');
    await db.delete('relationships');
    await db.delete('persons');
    await db.delete('families');
  }
}

/// Sync Action Types
enum SyncAction {
  create,
  update,
  delete,
}

/// Sync Entity Types
enum SyncEntityType {
  family,
  person,
  relationship,
  treePosition,
}

/// Sync Queue Item
class SyncQueueItem {
  final int? id;
  final SyncAction action;
  final SyncEntityType entityType;
  final int? entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final String status;
  final String? errorMessage;
  final int retryCount;

  const SyncQueueItem({
    this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.payload,
    required this.createdAt,
    this.status = 'pending',
    this.errorMessage,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'action': action.name,
        'entity_type': entityType.name,
        'entity_id': entityId,
        'payload': payload.toString(),
        'created_at': createdAt.toIso8601String(),
        'status': status,
        'error_message': errorMessage,
        'retry_count': retryCount,
      };
}
