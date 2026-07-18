import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'realtime_sync_service.dart';

class _WebRealtimeSyncService implements RealtimeSyncService {
  html.WebSocket? _socket;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;
  String? _baseUrl;
  String? _accessToken;
  RealtimeSignalCallback? _onSignal;

  @override
  Future<void> connect({
    required String baseUrl,
    required String accessToken,
    required RealtimeSignalCallback onSignal,
  }) async {
    _baseUrl = baseUrl;
    _accessToken = accessToken;
    _onSignal = onSignal;
    _intentionalClose = false;
    _reconnectTimer?.cancel();
    _openSocket();
  }

  void _openSocket() {
    final baseUrl = _baseUrl;
    final accessToken = _accessToken;
    final onSignal = _onSignal;
    if (baseUrl == null || accessToken == null || onSignal == null) return;

    try {
      _socket?.close();
      final uri = Uri.parse(baseUrl);
      final path = uri.path.endsWith('/ws') ? uri.path : '${uri.path}/ws';
      final wsUri = uri.replace(
        scheme: uri.scheme == 'https' ? 'wss' : 'ws',
        path: path,
        queryParameters: {'token': accessToken},
      );
      final socket = html.WebSocket(wsUri.toString());
      _socket = socket;
      socket.onMessage.listen((event) {
        try {
          final payload = jsonDecode('${event.data}');
          if (payload is Map && payload['type'] == 'sync_available') {
            onSignal();
          }
        } catch (_) {
          onSignal();
        }
      });
      socket.onClose.listen((_) => _scheduleReconnect());
      socket.onError.listen((_) => _scheduleReconnect());
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_intentionalClose) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), _openSocket);
  }

  @override
  Future<void> disconnect() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socket?.close();
    _socket = null;
  }
}

RealtimeSyncService createRealtimeSyncServiceImpl() => _WebRealtimeSyncService();
