import 'local_store_service_stub.dart'
    if (dart.library.html) 'local_store_service_web.dart'
    if (dart.library.io) 'local_store_service_io.dart';

abstract class LocalStoreService {
  Future<String?> loadSnapshotJson();
  Future<void> saveSnapshotJson(String json);
}

LocalStoreService createLocalStoreService() => createLocalStoreServiceImpl();
