import 'dart:html' as html;

import 'local_store_service.dart';

class _WebLocalStoreService implements LocalStoreService {
  static const _snapshotKey = 'kese_snapshot_json';

  @override
  Future<String?> loadSnapshotJson() async {
    final value = html.window.localStorage[_snapshotKey];
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  @override
  Future<void> saveSnapshotJson(String json) async {
    html.window.localStorage[_snapshotKey] = json;
  }
}

LocalStoreService createLocalStoreServiceImpl() => _WebLocalStoreService();
