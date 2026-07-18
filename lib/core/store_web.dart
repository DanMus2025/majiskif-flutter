import 'dart:convert';
import 'dart:html' as html;

import 'models.dart';
import 'store_interface.dart';

class BrowserAppStore implements AppStore {
  BrowserAppStore();

  static const String _storageKey = 'majiskif_store_v1';
  String _tenantKey = '';
  final Map<String, String> _kv = <String, String>{};
  final List<RecordEnvelope> _records = <RecordEnvelope>[];
  final List<ChangeEnvelope> _changes = <ChangeEnvelope>[];
  int _revision = 0;

  @override
  String get tenantKey => _tenantKey;

  @override
  Future<void> init(String tenantKey) async {
    _tenantKey = tenantKey;
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) {
      _persist();
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _kv
      ..clear()
      ..addAll(
        (decoded['kv'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            <String, String>{},
      );
    _records
      ..clear()
      ..addAll(
        ((decoded['records'] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => RecordEnvelope.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
      );
    _changes
      ..clear()
      ..addAll(
        ((decoded['changes'] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => ChangeEnvelope.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
      );
    _revision = asInt(decoded['revision']);
    _kv['tenantKey'] = tenantKey;
    _persist();
  }

  void _persist() {
    html.window.localStorage[_storageKey] = jsonEncode(<String, dynamic>{
      'kv': _kv,
      'records': _records
          .map((record) => record.toMap())
          .toList(growable: false),
      'changes': _changes
          .map((change) => change.toMap())
          .toList(growable: false),
      'revision': _revision,
    });
  }

  @override
  Future<void> setValue(String key, String value) async {
    _kv[key] = value;
    _persist();
  }

  @override
  Future<String?> getValue(String key) async => _kv[key];

  @override
  Future<void> removeValue(String key) async {
    _kv.remove(key);
    _persist();
  }

  @override
  Future<List<RecordEnvelope>> listRecords({
    String? type,
    bool includeDeleted = false,
  }) async {
    return _records
        .where((record) {
          if (record.tenantKey != _tenantKey) return false;
          if (type != null && record.type != type) return false;
          if (!includeDeleted && record.deleted) return false;
          return true;
        })
        .toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<RecordEnvelope?> getRecord(String type, String entityId) async {
    for (final record in _records.reversed) {
      if (record.tenantKey == _tenantKey &&
          record.type == type &&
          record.entityId == entityId) {
        return record;
      }
    }
    return null;
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
    final revision = revisionOverride ?? (_revision + 1);
    _revision = revision;
    final record = RecordEnvelope(
      id: '$type:$entityId',
      type: type,
      entityId: entityId,
      tenantKey: _tenantKey,
      payload: payload,
      updatedAt: DateTime.now().toUtc(),
      revision: revision,
      deleted: deleted,
    );
    _records.removeWhere(
      (item) => item.id == record.id && item.tenantKey == _tenantKey,
    );
    _records.add(record);
    if (queueChange) {
      final change = ChangeEnvelope(
        id: _changes.isEmpty
            ? 1
            : (_changes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1),
        operation: operation,
        record: record,
        createdAt: DateTime.now().toUtc(),
        synced: false,
      );
      _changes.add(change);
    }
    _kv['revision'] = _revision.toString();
    _persist();
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
    return _changes
        .where(
          (change) => change.record.tenantKey == _tenantKey && !change.synced,
        )
        .toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<void> markChangesSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    for (var i = 0; i < _changes.length; i++) {
      if (ids.contains(_changes[i].id)) {
        _changes[i] = ChangeEnvelope(
          id: _changes[i].id,
          operation: _changes[i].operation,
          record: _changes[i].record,
          createdAt: _changes[i].createdAt,
          synced: true,
        );
      }
    }
    _persist();
  }

  @override
  Future<int> getRevision() async => _revision;

  @override
  Future<void> setRevision(int revision) async {
    _revision = revision;
    _kv['revision'] = revision.toString();
    _persist();
  }

  @override
  Future<int> nextRevision() async {
    _revision += 1;
    await setRevision(_revision);
    return _revision;
  }

  @override
  Future<void> clearAll() async {
    _kv.clear();
    _records.clear();
    _changes.clear();
    _revision = 0;
    _persist();
  }
}

AppStore createAppStore() => BrowserAppStore();
