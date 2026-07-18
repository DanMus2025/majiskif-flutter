import 'models.dart';

abstract class AppStore {
  Future<void> init(String tenantKey);

  String get tenantKey;

  Future<void> setValue(String key, String value);
  Future<String?> getValue(String key);
  Future<void> removeValue(String key);

  Future<List<RecordEnvelope>> listRecords({
    String? type,
    bool includeDeleted = false,
  });

  Future<RecordEnvelope?> getRecord(String type, String entityId);

  Future<void> upsertRecord(
    String type,
    String entityId,
    Map<String, dynamic> payload, {
    bool deleted = false,
    bool queueChange = true,
    String operation = 'upsert',
    int? revisionOverride,
  });

  Future<void> markDeleted(
    String type,
    String entityId, {
    bool queueChange = true,
  });

  Future<List<ChangeEnvelope>> pendingChanges();

  Future<void> markChangesSynced(List<int> ids);

  Future<int> getRevision();
  Future<void> setRevision(int revision);
  Future<int> nextRevision();

  Future<void> clearAll();
}
