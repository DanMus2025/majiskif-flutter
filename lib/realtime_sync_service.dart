import 'realtime_sync_service_stub.dart'
    if (dart.library.html) 'realtime_sync_service_web.dart';

typedef RealtimeSignalCallback = void Function();

abstract class RealtimeSyncService {
  Future<void> connect({
    required String baseUrl,
    required String accessToken,
    required RealtimeSignalCallback onSignal,
  });

  Future<void> disconnect();
}

RealtimeSyncService createRealtimeSyncService() => createRealtimeSyncServiceImpl();
