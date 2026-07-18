import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:majiskif/core/app.dart';
import 'package:majiskif/core/app_controller.dart';
import 'package:majiskif/core/store_interface.dart';

class _SmokeStore implements AppStore {
  final Map<String, String> _kv = <String, String>{};
  String _tenantKey = 'system';

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
  Future<int> getRevision() async => 0;

  @override
  Future<void> markChangesSynced(List<int> ids) async {}

  @override
  Future<void> markDeleted(String type, String entityId, {bool queueChange = true}) async {}

  @override
  Future<List<ChangeEnvelope>> pendingChanges() async => const <ChangeEnvelope>[];

  @override
  Future<int> nextRevision() async => 1;

  @override
  Future<void> removeValue(String key) async {
    _kv.remove(key);
  }

  @override
  Future<void> setRevision(int revision) async {}

  @override
  Future<void> setValue(String key, String value) async {
    _kv[key] = value;
  }

  @override
  Future<List<RecordEnvelope>> listRecords({String? type, bool includeDeleted = false}) async => const <RecordEnvelope>[];

  @override
  Future<void> upsertRecord(
    String type,
    String entityId,
    Map<String, dynamic> payload, {
    bool deleted = false,
    bool queueChange = true,
    String operation = 'upsert',
    int? revisionOverride,
  }) async {}
}

void main() {
  testWidgets('app builds the startup gate', (tester) async {
    final controller = AppController(store: _SmokeStore());
    await tester.pumpWidget(MajiskifApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

