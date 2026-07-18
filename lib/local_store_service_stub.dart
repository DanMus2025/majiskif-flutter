import 'local_store_service.dart';

class _StubLocalStoreService implements LocalStoreService {
  @override
  Future<String?> loadSnapshotJson() async => null;

  @override
  Future<void> saveSnapshotJson(String json) async {}
}

LocalStoreService createLocalStoreServiceImpl() => _StubLocalStoreService();
