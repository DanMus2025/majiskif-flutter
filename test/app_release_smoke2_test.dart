import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:majiskif/core/app_controller.dart';
import 'package:majiskif/core/app_release.dart';
import 'package:majiskif/core/models.dart';
import 'package:majiskif/core/store_interface.dart';

class _SmokeStore2 implements AppStore {
  final Map<String, String> _kv = <String, String>{};
  final Map<String, List<RecordEnvelope>> _records = <String, List<RecordEnvelope>>{};
  String _tenantKey = 'system';
  int _revision = 0;

  @override
  String get tenantKey => _tenantKey;

  @override
  Future<void> init(String tenantKey) async {
    _tenantKey = tenantKey;
  }

  @override
  Future<void> clearAll() async {}

  @override
  Future<RecordEnvelope?> getRecord(String type, String entityId) async => null;

  @override
  Future<String?> getValue(String key) async => _kv[key];

  @override
  Future<int> getRevision() async => _revision;

  @override
  Future<void> markChangesSynced(List<int> ids) async {}

  @override
  Future<void> markDeleted(String type, String entityId, {bool queueChange = true}) async {}

  @override
  Future<List<ChangeEnvelope>> pendingChanges() async => const <ChangeEnvelope>[];

  @override
  Future<int> nextRevision() async => ++_revision;

  @override
  Future<void> removeValue(String key) async => _kv.remove(key);

  @override
  Future<void> setRevision(int revision) async {
    _revision = revision;
  }

  @override
  Future<void> setValue(String key, String value) async {
    _kv[key] = value;
  }

  @override
  Future<List<RecordEnvelope>> listRecords({String? type, bool includeDeleted = false}) async {
    final results = <RecordEnvelope>[];
    for (final entry in _records.entries) {
      if (type != null && entry.key != type) continue;
      results.addAll(entry.value.where((item) => item.tenantKey == _tenantKey));
    }
    return results;
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
    final record = RecordEnvelope(
      id: '$type:$entityId',
      type: type,
      entityId: entityId,
      tenantKey: _tenantKey,
      payload: payload,
      updatedAt: DateTime.now().toUtc(),
      revision: revisionOverride ?? ++_revision,
      deleted: deleted,
    );
    final list = _records.putIfAbsent(type, () => <RecordEnvelope>[]);
    list.removeWhere((item) => item.entityId == entityId && item.tenantKey == _tenantKey);
    list.add(record);
  }
}

void main() {
  testWidgets('release app boots and shows a scaffold', (tester) async {
    final controller = AppController(store: _SmokeStore2());
    await tester.pumpWidget(MajiskifApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });
}

