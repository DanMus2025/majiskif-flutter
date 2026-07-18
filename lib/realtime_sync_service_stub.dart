import 'realtime_sync_service.dart';

class _StubRealtimeSyncService implements RealtimeSyncService {
  @override
  Future<void> connect({
    required String baseUrl,
    required String accessToken,
    required RealtimeSignalCallback onSignal,
  }) async {}

  @override
  Future<void> disconnect() async {}
}

RealtimeSyncService createRealtimeSyncServiceImpl() => _StubRealtimeSyncService();
