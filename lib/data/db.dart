import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

// Singleton class to manage the SQLite database
class AppDb {
  AppDb._();
  static final AppDb I = AppDb._();

  static const _name = 'traceit.db';
  static const _version = 1;
  Database? _db;

  // if already opened, return it; else, open the database
  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _name);
    _db = await openDatabase(
      path,
      version: _version,
      onConfigure: (d) async {
        await d.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  // handle database upgrades here
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // create database schema here
  Future<void> _onCreate(Database d, int v) async {
    await d.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    // Create categories table
    await d.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL
      )
    ''');
    // Create locations table
    await d.execute('''
      CREATE TABLE locations(
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL
      )
    ''');
    // Create items table
    await d.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category_id TEXT,
        status TEXT NOT NULL,
        found_time TEXT NOT NULL,
        found_location_id TEXT,
        reported_by TEXT NOT NULL,
        claimed_by TEXT,
        storage_ref TEXT,
        primary_photo_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET NULL,
        FOREIGN KEY(found_location_id) REFERENCES locations(id) ON DELETE SET NULL,
        FOREIGN KEY(reported_by) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(claimed_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');
    // Create photos table
    await d.execute('''
      CREATE TABLE photos(
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');
    // Create claims table
    await d.execute('''
      CREATE TABLE claims(
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        claimer_id TEXT NOT NULL,
        status TEXT NOT NULL,
        submitted_at TEXT NOT NULL,
        resolved_at TEXT,
        notes TEXT,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE,
        FOREIGN KEY(claimer_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    // Create indexes for performance optimization
    await d.execute('CREATE INDEX idx_items_status ON items(status)');
    await d.execute(
      'CREATE INDEX idx_items_found_time ON items(found_time DESC)',
    );
    await d.execute('CREATE INDEX idx_items_category ON items(category_id)');
    await d.execute(
      'CREATE INDEX idx_items_location ON items(found_location_id)',
    );
    await d.execute('CREATE INDEX idx_items_reported_by ON items(reported_by)');
    await d.execute('CREATE INDEX idx_photos_item ON photos(item_id)');
    await d.execute('CREATE INDEX idx_claims_item ON claims(item_id)');
    await d.execute('CREATE INDEX idx_claims_claimer ON claims(claimer_id)');
  }

  // reset the database by deleting all data from all tables
  Future<void> resetApp() async {
    final d = await db;
    await d.delete('claims');
    await d.delete('photos');
    await d.delete('items');
    await d.delete('categories');
    await d.delete('locations');
    await d.delete('users');
  }

  // CRUD operations and queries below
  Future<int> insertItem(TItem it) async => (await db).insert(
    'items',
    it.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<int> updateItem(TItem it) async =>
      (await db).update('items', it.toMap(), where: 'id=?', whereArgs: [it.id]);

  Future<int> deleteItem(String id) async =>
      (await db).delete('items', where: 'id=?', whereArgs: [id]);

  // fetch items with optional filters
  Future<List<TItem>> items({
    String? status,
    String? categoryId,
    String? locationId,
    String? reportedBy,
    String? claimedBy,
    String? query,
    bool newestFirst = true,
  }) async {
    // build where clause dynamically, based on provided filters
    final w = <String>[];
    final a = <Object?>[];
    if (status != null) {
      w.add('status=?');
      a.add(status);
    }
    if (categoryId != null) {
      w.add('category_id=?');
      a.add(categoryId);
    }
    if (locationId != null) {
      w.add('found_location_id=?');
      a.add(locationId);
    }
    if (reportedBy != null) {
      w.add('reported_by=?');
      a.add(reportedBy);
    }
    if (claimedBy != null) {
      w.add('claimed_by=?');
      a.add(claimedBy);
    }
    if (query != null && query.trim().isNotEmpty) {
      w.add('(title LIKE ? OR description LIKE ?)');
      final q = '%${query.trim()}%';
      a.addAll([q, q]);
    }
    // execute query
    final rows = await (await db).query(
      'items',
      where: w.isEmpty ? null : w.join(' AND '),
      whereArgs: w.isEmpty ? null : a,
      orderBy: newestFirst
          ? 'datetime(updated_at) DESC'
          : 'datetime(found_time) ASC',
    );
    return rows.map(TItem.fromMap).toList();
  }

  // get item counts by status
  Future<Map<String, int>> itemCounters() async {
    final d = await db;

    Future<int> c(String where, [List<Object?> args = const []]) async {
      return Sqflite.firstIntValue(
            await d.rawQuery('SELECT COUNT(*) FROM items $where', args),
          ) ??
          0;
    }

    final total = await c('');
    final lost = await c('WHERE status=?', ['lost']);
    final returned = await c('WHERE status=?', ['returned']);
    final archived = await c('WHERE status=?', ['archived']);

    return {
      'total': total,
      'lost': lost,
      'returned': returned,
      'archived': archived,
    };
  }

  // upsert category
  Future<int> upsertCategory(String id, String name) async => (await db).insert(
    'categories',
    {'id': id, 'name': name},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  // upsert location
  Future<int> upsertLocation(String id, String name) async => (await db).insert(
    'locations',
    {'id': id, 'name': name},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  // upsert user
  Future<int> upsertUser({
    required String id,
    required String name,
    String? email,
    required String role,
    required String createdAtIso,
  }) async {
    return (await db).insert('users', {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAtIso,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // insert photo
  Future<int> insertPhoto({
    required String id,
    required String itemId,
    required String path,
    required String createdAtIso,
  }) async => (await db).insert('photos', {
    'id': id,
    'item_id': itemId,
    'path': path,
    'created_at': createdAtIso,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  // fetch photos for an item
  Future<List<Map<String, dynamic>>> itemPhotos(String itemId) async =>
      (await db).query(
        'photos',
        where: 'item_id=?',
        whereArgs: [itemId],
        orderBy: 'datetime(created_at) DESC',
      );
  // create a claim
  Future<int> createClaim({
    required String id,
    required String itemId,
    required String claimerId,
    required String status,
    required String submittedAtIso,
    String? notes,
  }) async => (await db).insert('claims', {
    'id': id,
    'item_id': itemId,
    'claimer_id': claimerId,
    'status': status,
    'submitted_at': submittedAtIso,
    'resolved_at': null,
    'notes': notes,
  }, conflictAlgorithm: ConflictAlgorithm.fail);
  // update claim status
  Future<int> updateClaimStatus({
    required String claimId,
    required String status,
    String? resolvedAtIso,
    String? notes,
  }) async => (await db).update(
    'claims',
    {'status': status, 'resolved_at': resolvedAtIso, 'notes': notes},
    where: 'id=?',
    whereArgs: [claimId],
  );
  // fetch claims for an item
  Future<List<Map<String, dynamic>>> claimsForItem(String itemId) async =>
      (await db).query(
        'claims',
        where: 'item_id=?',
        whereArgs: [itemId],
        orderBy: 'datetime(submitted_at) DESC',
      );
  // fetch claims for a user
  Future<List<Map<String, dynamic>>> claimsForUser(String userId) async =>
      (await db).query(
        'claims',
        where: 'claimer_id=?',
        whereArgs: [userId],
        orderBy: 'datetime(submitted_at) DESC',
      );
}
