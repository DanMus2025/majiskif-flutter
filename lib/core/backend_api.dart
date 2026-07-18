import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class CloudApi {
  CloudApi(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUrl;
  final http.Client _client;

  Uri _resolve(String path) =>
      baseUrl.resolve(path.startsWith('/') ? path.substring(1) : path);

  Future<Map<String, dynamic>> activateLicense({
    required String licenseKey,
    required String deviceId,
    required String deviceName,
  }) async {
    final response = await _client.post(
      _resolve('/license/activate'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'license_key': licenseKey,
        'device_id': deviceId,
        'device_name': deviceName,
      }),
    );
    return _decodeOk(response);
  }

  Future<Map<String, dynamic>> validateLicense({
    required String licenseKey,
    required String deviceId,
  }) async {
    final response = await _client.post(
      _resolve('/license/validate'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'license_key': licenseKey,
        'device_id': deviceId,
      }),
    );
    return _decodeOk(response);
  }

  Future<Map<String, dynamic>> pushChanges({
    required String tenantKey,
    required String deviceId,
    required int sinceRevision,
    required List<ChangeEnvelope> changes,
  }) async {
    final response = await _client.post(
      _resolve('/sync/push'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'tenant_key': tenantKey,
        'device_id': deviceId,
        'since_revision': sinceRevision,
        'changes': changes
            .map((change) => change.toMap())
            .toList(growable: false),
      }),
    );
    return _decodeOk(response);
  }

  Future<Map<String, dynamic>> pullChanges({
    required String tenantKey,
    required String deviceId,
    required int sinceRevision,
  }) async {
    final response = await _client.get(
      _resolve(
        '/sync/pull?tenant_key=$tenantKey&device_id=$deviceId&since_revision=$sinceRevision',
      ),
      headers: _jsonHeaders,
    );
    return _decodeOk(response);
  }

  Map<String, String> get _jsonHeaders => const <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudApiException('HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw CloudApiException('Invalid cloud response');
  }
}

class CloudApiException implements Exception {
  CloudApiException(this.message);
  final String message;

  @override
  String toString() => 'CloudApiException: $message';
}
