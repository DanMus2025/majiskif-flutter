import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'models.dart';
import 'store_interface.dart';

class SqliteAppStore implements AppStore {
  Database? _db;
  String _tenantKey = '';

  @override
  String get tenantKey => _tenantKey;

  @override
  Future<void> init(String tenantKey) async {
    _tenantKey = tenantKey;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final supportDir = await getApplicationSupportDirectory();
    final dbPath = p.join(supportDir.path, 'majiskif_store.sqlite');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('PRAGMA journal_mode = WAL');
        await db.execute('PRAGMA synchronous = NORMAL');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kv (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE records (
            id TEXT PRIMARY KEY,
            tenantKey TEXT NOT NULL,
            type TEXT NOT NULL,
            entityId TEXT NOT NULL,
            payload TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            revision INTEGER NOT NULL,
            deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE changes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tenantKey TEXT NOT NULL,
            operation TEXT NOT NULL,
            type TEXT NOT NULL,
            recordId TEXT NOT NULL,
            payload TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_records_tenant_type ON records(tenantKey, type, updatedAt DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_changes_sync ON changes(tenantKey, synced, id)',
        );
      },
    );
    await setValue('tenantKey', tenantKey);
    final existingRevision = await getRevision();
    if (existingRevision <= 0) {
      await setRevision(1);
    }
  }

  Database get _requiredDb {
    final db = _db;
    if (db == null) {
      throw StateError('Store not initialized');
    }
    return db;
  }

  @override
  Future<void> setValue(String key, String value) async {
    await _requiredDb.insert('kv', <String, Object?>{
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> getValue(String key) async {
    final rows = await _requiredDb.query(
      'kv',
      where: 'key = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value']?.toString();
  }

  @override
  Future<void> removeValue(String key) async {
    await _requiredDb.delete('kv', where: 'key = ?', whereArgs: <Object?>[key]);
  }

  @override
  Future<List<RecordEnvelope>> listRecords({
    String? type,
    bool includeDeleted = false,
  }) async {
    final where = <String>['tenantKey = ?'];
    final args = <Object?>[_tenantKey];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (!includeDeleted) {
      where.add('deleted = 0');
    }
    final rows = await _requiredDb.query(
      'records',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'updatedAt DESC',
    );
    return rows
        .map(
          (row) => RecordEnvelope.fromMap(<String, dynamic>{
            'id': row['id'],
            'type': row['type'],
            'entityId': row['entityId'],
            'tenantKey': row['tenantKey'],
            'payload': jsonDecode(row['payload'] as String),
            'updatedAt': row['updatedAt'],
            'revision': row['revision'],
            'deleted': row['deleted'] == 1,
          }),
        )
        .toList(growable: false);
  }

  @override
  Future<RecordEnvelope?> getRecord(String type, String entityId) async {
    final rows = await _requiredDb.query(
      'records',
      where: 'tenantKey = ? AND type = ? AND entityId = ?',
      whereArgs: <Object?>[_tenantKey, type, entityId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RecordEnvelope.fromMap(<String, dynamic>{
      'id': rows.first['id'],
      'type': rows.first['type'],
      'entityId': rows.first['entityId'],
      'tenantKey': rows.first['tenantKey'],
      'payload': jsonDecode(rows.first['payload'] as String),
      'updatedAt': rows.first['updatedAt'],
      'revision': rows.first['revision'],
      'deleted': rows.first['deleted'] == 1,
    });
  }

  @override
  Future<void> upsertRecord(
    String type,
    String entityId,
    Map<String, dynamic> payload, {
    bool deleted = false,
    bool queueChange = true,
    String operation = 'upsert',
    int? revisionOverride,
  }) async {
    final db = _requiredDb;
    await db.transaction((txn) async {
      final revision = revisionOverride ?? ((await getRevision()) + 1);
      await txn.insert('records', <String, Object?>{
        'id': '$type:$entityId',
        'tenantKey': _tenantKey,
        'type': type,
        'entityId': entityId,
        'payload': jsonEncode(payload),
        'updatedAt': isoNow(),
        'revision': revision,
        'deleted': deleted ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await setRevision(revision);
      if (queueChange) {
        await txn.insert('changes', <String, Object?>{
          'tenantKey': _tenantKey,
          'operation': operation,
          'type': type,
          'recordId': '$type:$entityId',
          'payload': jsonEncode(<String, dynamic>{
            'record': <String, dynamic>{
              'id': '$type:$entityId',
              'tenantKey': _tenantKey,
              'type': type,
              'entityId': entityId,
              'payload': payload,
              'updatedAt': isoNow(),
              'revision': revision,
              'deleted': deleted,
            },
          }),
          'createdAt': isoNow(),
          'synced': 0,
        });
      }
    });
  }

  @override
  Future<void> markDeleted(
    String type,
    String entityId, {
    bool queueChange = true,
  }) {
    return upsertRecord(
      type,
      entityId,
      <String, dynamic>{'deleted': true},
      deleted: true,
      queueChange: queueChange,
      operation: 'delete',
    );
  }

  @override
  Future<List<ChangeEnvelope>> pendingChanges() async {
    final rows = await _requiredDb.query(
      'changes',
      where: 'tenantKey = ? AND synced = 0',
      whereArgs: <Object?>[_tenantKey],
      orderBy: 'id ASC',
    );
    return rows
        .map((row) {
          final payload =
              jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          return ChangeEnvelope(
            id: row['id'] as int,
            operation: row['operation'] as String,
            record: RecordEnvelope.fromMap(
              payload['record'] as Map<String, dynamic>,
            ),
            createdAt: parseUtc(row['createdAt'] as String),
            synced: row['synced'] == 1,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> markChangesSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List<String>.filled(ids.length, '?').join(',');
    await _requiredDb.update(
      'changes',
      <String, Object?>{'synced': 1},
      where: 'tenantKey = ? AND id IN ($placeholders)',
      whereArgs: <Object?>[_tenantKey, ...ids],
    );
  }

  @override
  Future<int> getRevision() async {
    final raw = await getValue('revision');
    return int.tryParse(raw ?? '') ?? 0;
  }

  @override
  Future<void> setRevision(int revision) =>
      setValue('revision', revision.toString());

  @override
  Future<int> nextRevision() async {
    final revision = (await getRevision()) + 1;
    await setRevision(revision);
    return revision;
  }

  @override
  Future<void> clearAll() async {
    final db = _requiredDb;
    await db.transaction((txn) async {
      await txn.delete(
        'changes',
        where: 'tenantKey = ?',
        whereArgs: <Object?>[_tenantKey],
      );
      await txn.delete(
        'records',
        where: 'tenantKey = ?',
        whereArgs: <Object?>[_tenantKey],
      );
      await txn.delete('kv');
      await txn.insert('kv', <String, Object?>{
        'key': 'tenantKey',
        'value': _tenantKey,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('kv', <String, Object?>{
        'key': 'revision',
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}

AppStore createAppStore() => SqliteAppStore();
