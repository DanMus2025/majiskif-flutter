import 'dart:convert';

import 'package:http/http.dart' as http;

class KeseCloudException implements Exception {
  const KeseCloudException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class KeseCloudTenant {
  const KeseCloudTenant({
    required this.id,
    required this.tenantKey,
    required this.companyName,
    required this.cloudBaseUrl,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
  });

  final int id;
  final String tenantKey;
  final String companyName;
  final String? cloudBaseUrl;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? address;

  factory KeseCloudTenant.fromJson(Map<String, dynamic> json) =>
      KeseCloudTenant(
        id: (json['id'] as num?)?.toInt() ?? 0,
        tenantKey: (json['tenant_key'] ?? '').toString(),
        companyName: (json['company_name'] ?? '').toString(),
        cloudBaseUrl: json['cloud_base_url']?.toString(),
        ownerName: json['owner_name']?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        address: json['address']?.toString(),
      );
}

class KeseCloudBranch {
  const KeseCloudBranch({
    required this.id,
    required this.branchCode,
    required this.branchName,
    required this.address,
    required this.isMain,
  });

  final int id;
  final String branchCode;
  final String branchName;
  final String? address;
  final bool isMain;

  factory KeseCloudBranch.fromJson(Map<String, dynamic> json) =>
      KeseCloudBranch(
        id: (json['id'] as num?)?.toInt() ?? 0,
        branchCode: (json['branch_code'] ?? '').toString(),
        branchName: (json['branch_name'] ?? '').toString(),
        address: json['address']?.toString(),
        isMain: json['is_main'] == true,
      );
}

class KeseCloudUser {
  const KeseCloudUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isBlocked,
  });

  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isBlocked;

  factory KeseCloudUser.fromJson(Map<String, dynamic> json) => KeseCloudUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: (json['username'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        isBlocked: json['is_blocked'] == true,
      );
}

class KeseCloudDevice {
  const KeseCloudDevice({
    required this.id,
    required this.deviceUuid,
    required this.deviceLabel,
    required this.platformName,
    required this.appVersion,
    required this.isActive,
  });

  final int id;
  final String deviceUuid;
  final String deviceLabel;
  final String platformName;
  final String? appVersion;
  final bool isActive;

  factory KeseCloudDevice.fromJson(Map<String, dynamic> json) => KeseCloudDevice(
        id: (json['id'] as num?)?.toInt() ?? 0,
        deviceUuid: (json['device_uuid'] ?? '').toString(),
        deviceLabel: (json['device_label'] ?? '').toString(),
        platformName: (json['platform_name'] ?? '').toString(),
        appVersion: json['app_version']?.toString(),
        isActive: json['is_active'] == true,
      );
}

class KeseCloudLicense {
  const KeseCloudLicense({
    required this.id,
    required this.licenseCode,
    required this.planCode,
    required this.status,
    required this.maxDevices,
    required this.maxUsers,
    required this.expiresAt,
    required this.activatedAt,
  });

  final int id;
  final String licenseCode;
  final String planCode;
  final String status;
  final int maxDevices;
  final int maxUsers;
  final DateTime? expiresAt;
  final DateTime? activatedAt;

  factory KeseCloudLicense.fromJson(Map<String, dynamic> json) =>
      KeseCloudLicense(
        id: (json['id'] as num?)?.toInt() ?? 0,
        licenseCode: (json['license_code'] ?? '').toString(),
        planCode: (json['plan_code'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        maxDevices: (json['max_devices'] as num?)?.toInt() ?? 0,
        maxUsers: (json['max_users'] as num?)?.toInt() ?? 20,
        expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
        activatedAt: DateTime.tryParse((json['activated_at'] ?? '').toString()),
      );
}

class KeseCloudAuthResponse {
  const KeseCloudAuthResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.tenant,
    required this.branch,
    required this.user,
    required this.device,
    required this.license,
  });

  final String accessToken;
  final DateTime expiresAt;
  final KeseCloudTenant tenant;
  final KeseCloudBranch branch;
  final KeseCloudUser user;
  final KeseCloudDevice device;
  final KeseCloudLicense license;

  factory KeseCloudAuthResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudAuthResponse(
        accessToken: (json['access_token'] ?? '').toString(),
        expiresAt:
            DateTime.tryParse((json['expires_at'] ?? '').toString()) ??
                DateTime.now().add(const Duration(hours: 8)),
        tenant: KeseCloudTenant.fromJson(
          (json['tenant'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        branch: KeseCloudBranch.fromJson(
          (json['branch'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        user: KeseCloudUser.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        device: KeseCloudDevice.fromJson(
          (json['device'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        license: KeseCloudLicense.fromJson(
          (json['license'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
      );
}

class KeseCloudBootstrapResponse {
  const KeseCloudBootstrapResponse({
    required this.tenant,
    required this.branch,
    required this.user,
    required this.devices,
    required this.users,
    required this.license,
  });

  final KeseCloudTenant tenant;
  final KeseCloudBranch branch;
  final KeseCloudUser user;
  final List<KeseCloudDevice> devices;
  final List<KeseCloudUser> users;
  final KeseCloudLicense license;

  factory KeseCloudBootstrapResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudBootstrapResponse(
        tenant: KeseCloudTenant.fromJson(
          (json['tenant'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        branch: KeseCloudBranch.fromJson(
          (json['branch'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        user: KeseCloudUser.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        devices: ((json['devices'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => KeseCloudDevice.fromJson(item.cast<String, dynamic>()))
            .toList(),
        users: ((json['users'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => KeseCloudUser.fromJson(item.cast<String, dynamic>()))
            .toList(),
        license: KeseCloudLicense.fromJson(
          (json['license'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
      );
}

class KeseCloudTenantCreateResponse {
  const KeseCloudTenantCreateResponse({
    required this.tenant,
    required this.branch,
    required this.adminUser,
    required this.license,
    required this.activationHint,
  });

  final KeseCloudTenant tenant;
  final KeseCloudBranch branch;
  final KeseCloudUser adminUser;
  final KeseCloudLicense license;
  final Map<String, dynamic> activationHint;

  factory KeseCloudTenantCreateResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudTenantCreateResponse(
        tenant: KeseCloudTenant.fromJson(
          (json['tenant'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        branch: KeseCloudBranch.fromJson(
          (json['branch'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        adminUser: KeseCloudUser.fromJson(
          (json['admin_user'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        license: KeseCloudLicense.fromJson(
          (json['license'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        activationHint:
            (json['activation_hint'] as Map?)?.cast<String, dynamic>() ??
                <String, dynamic>{},
      );
}

class KeseCloudCreatorAuthResponse {
  const KeseCloudCreatorAuthResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.username,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String username;

  factory KeseCloudCreatorAuthResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudCreatorAuthResponse(
        accessToken: (json['access_token'] ?? '').toString(),
        expiresAt:
            DateTime.tryParse((json['expires_at'] ?? '').toString()) ??
                DateTime.now().add(const Duration(hours: 8)),
        username: (json['username'] ?? '').toString(),
      );
}

class KeseCloudCreatorTenantOverview {
  const KeseCloudCreatorTenantOverview({
    required this.tenant,
    required this.branch,
    required this.license,
    required this.usersCount,
    required this.devicesCount,
    required this.activeDevicesCount,
    required this.firstActivationDone,
    required this.lastActivityAt,
  });

  final KeseCloudTenant tenant;
  final KeseCloudBranch branch;
  final KeseCloudLicense license;
  final int usersCount;
  final int devicesCount;
  final int activeDevicesCount;
  final bool firstActivationDone;
  final DateTime? lastActivityAt;

  factory KeseCloudCreatorTenantOverview.fromJson(Map<String, dynamic> json) =>
      KeseCloudCreatorTenantOverview(
        tenant: KeseCloudTenant.fromJson(
          (json['tenant'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        branch: KeseCloudBranch.fromJson(
          (json['branch'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        license: KeseCloudLicense.fromJson(
          (json['license'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{},
        ),
        usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
        devicesCount: (json['devices_count'] as num?)?.toInt() ?? 0,
        activeDevicesCount: (json['active_devices_count'] as num?)?.toInt() ?? 0,
        firstActivationDone: json['first_activation_done'] == true,
        lastActivityAt: DateTime.tryParse(
          (json['last_activity_at'] ?? '').toString(),
        ),
      );
}

class KeseCloudCreatorTenantsResponse {
  const KeseCloudCreatorTenantsResponse({
    required this.items,
    required this.total,
  });

  final List<KeseCloudCreatorTenantOverview> items;
  final int total;

  factory KeseCloudCreatorTenantsResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      KeseCloudCreatorTenantsResponse(
        total: (json['total'] as num?)?.toInt() ?? 0,
        items: ((json['items'] as List?) ?? const [])
            .whereType<Map>()
            .map(
              (item) => KeseCloudCreatorTenantOverview.fromJson(
                item.cast<String, dynamic>(),
              ),
            )
            .toList(),
      );
}

class KeseCloudLicenseUpdateResponse {
  const KeseCloudLicenseUpdateResponse({required this.license});

  final KeseCloudLicense license;
}

class KeseCloudCreatorSession {
  const KeseCloudCreatorSession({
    required this.baseUrl,
    required this.accessToken,
    required this.username,
    required this.expiresAt,
  });

  final String baseUrl;
  final String accessToken;
  final String username;
  final DateTime expiresAt;
}

class KeseCloudSession {
  const KeseCloudSession({
    required this.baseUrl,
    required this.accessToken,
    required this.tenantKey,
    required this.licenseCode,
    required this.deviceUuid,
    required this.deviceLabel,
    required this.platformName,
    required this.username,
    required this.role,
    required this.lastPulledOperationId,
    required this.connectedAt,
    required this.expiresAt,
  });

  final String baseUrl;
  final String accessToken;
  final String tenantKey;
  final String licenseCode;
  final String deviceUuid;
  final String deviceLabel;
  final String platformName;
  final String username;
  final String role;
  final int lastPulledOperationId;
  final DateTime connectedAt;
  final DateTime expiresAt;

  KeseCloudSession copyWith({
    String? baseUrl,
    String? accessToken,
    String? tenantKey,
    String? licenseCode,
    String? deviceUuid,
    String? deviceLabel,
    String? platformName,
    String? username,
    String? role,
    int? lastPulledOperationId,
    DateTime? connectedAt,
    DateTime? expiresAt,
  }) =>
      KeseCloudSession(
        baseUrl: baseUrl ?? this.baseUrl,
        accessToken: accessToken ?? this.accessToken,
        tenantKey: tenantKey ?? this.tenantKey,
        licenseCode: licenseCode ?? this.licenseCode,
        deviceUuid: deviceUuid ?? this.deviceUuid,
        deviceLabel: deviceLabel ?? this.deviceLabel,
        platformName: platformName ?? this.platformName,
        username: username ?? this.username,
        role: role ?? this.role,
        lastPulledOperationId:
            lastPulledOperationId ?? this.lastPulledOperationId,
        connectedAt: connectedAt ?? this.connectedAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'accessToken': accessToken,
        'tenantKey': tenantKey,
        'licenseCode': licenseCode,
        'deviceUuid': deviceUuid,
        'deviceLabel': deviceLabel,
        'platformName': platformName,
        'username': username,
        'role': role,
        'lastPulledOperationId': lastPulledOperationId,
        'connectedAt': connectedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory KeseCloudSession.fromJson(Map<String, dynamic> json) =>
      KeseCloudSession(
        baseUrl: (json['baseUrl'] ?? '').toString(),
        accessToken: (json['accessToken'] ?? '').toString(),
        tenantKey: (json['tenantKey'] ?? '').toString(),
        licenseCode: (json['licenseCode'] ?? '').toString(),
        deviceUuid: (json['deviceUuid'] ?? '').toString(),
        deviceLabel: (json['deviceLabel'] ?? '').toString(),
        platformName: (json['platformName'] ?? 'flutter').toString(),
        username: (json['username'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        lastPulledOperationId: (json['lastPulledOperationId'] as num?)?.toInt() ?? 0,
        connectedAt:
            DateTime.tryParse((json['connectedAt'] ?? '').toString()) ??
                DateTime.now(),
        expiresAt: DateTime.tryParse((json['expiresAt'] ?? '').toString()) ??
            DateTime.now().add(const Duration(hours: 8)),
      );
}

class KeseCloudSyncOperation {
  const KeseCloudSyncOperation({
    required this.id,
    required this.entityName,
    required this.entityId,
    required this.operationName,
    required this.payloadJson,
    required this.payloadHash,
    required this.syncStatus,
    required this.conflictReason,
    required this.createdAt,
  });

  final String id;
  final String entityName;
  final String entityId;
  final String operationName;
  final String payloadJson;
  final String? payloadHash;
  final String syncStatus;
  final String? conflictReason;
  final DateTime createdAt;

  factory KeseCloudSyncOperation.fromJson(Map<String, dynamic> json) =>
      KeseCloudSyncOperation(
        id: (json['operation_uid'] ?? '').toString(),
        entityName: (json['entity_name'] ?? '').toString(),
        entityId: (json['entity_id'] ?? '').toString(),
        operationName: (json['operation_name'] ?? '').toString(),
        payloadJson: (json['payload_json'] ?? '{}').toString(),
        payloadHash: json['payload_hash']?.toString(),
        syncStatus: (json['sync_status'] ?? 'pending').toString(),
        conflictReason: json['conflict_reason']?.toString(),
        createdAt:
            DateTime.tryParse((json['created_at'] ?? '').toString()) ??
                DateTime.now(),
      );
}

class KeseCloudPushResponse {
  const KeseCloudPushResponse({
    required this.accepted,
    required this.ignored,
    required this.conflicts,
    required this.operations,
  });

  final int accepted;
  final int ignored;
  final int conflicts;
  final List<KeseCloudSyncOperation> operations;

  factory KeseCloudPushResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudPushResponse(
        accepted: (json['accepted'] as num?)?.toInt() ?? 0,
        ignored: (json['ignored'] as num?)?.toInt() ?? 0,
        conflicts: (json['conflicts'] as num?)?.toInt() ?? 0,
        operations: ((json['operations'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => KeseCloudSyncOperation.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
}

class KeseCloudPullResponse {
  const KeseCloudPullResponse({
    required this.cursor,
    required this.operations,
  });

  final int cursor;
  final List<KeseCloudSyncOperation> operations;

  factory KeseCloudPullResponse.fromJson(Map<String, dynamic> json) =>
      KeseCloudPullResponse(
        cursor: (json['cursor'] as num?)?.toInt() ?? 0,
        operations: ((json['operations'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => KeseCloudSyncOperation.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
}

class KeseCloudService {
  KeseCloudService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String normalizeLicenseCode(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static String normalizeBaseUrl(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) {
      normalized = 'https://majiskif-kese-cloud-api.onrender.com/api/v1/cloud';
    }
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }
    normalized = normalized.replaceAll(RegExp(r'/+$'), '');
    if (!normalized.endsWith('/api/v1/cloud')) {
      if (normalized.endsWith('/api/v1')) {
        normalized = '$normalized/cloud';
      } else if (normalized.endsWith('/cloud')) {
        // keep as is
      } else {
        normalized = '$normalized/api/v1/cloud';
      }
    }
    return normalized;
  }

  Future<http.Response> _send(Future<http.Response> future) => future;

  Future<KeseCloudAuthResponse> activate({
    required String baseUrl,
    required String licenseCode,
    required String username,
    required String pin,
    required String deviceUuid,
    required String deviceLabel,
    required String platformName,
    required String appVersion,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/activate'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'license_code': normalizeLicenseCode(licenseCode),
        'username': username.trim(),
        'pin': pin.trim(),
        'device_uuid': deviceUuid.trim(),
        'device_label': deviceLabel.trim(),
        'platform_name': platformName.trim(),
        'app_version': appVersion.trim(),
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudAuthResponse.fromJson(json);
  }

  Future<KeseCloudTenantCreateResponse> createTenant({
    required String baseUrl,
    required String accessToken,
    required String companyName,
    String? cloudBaseUrl,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String branchName,
    required String adminFullName,
    required String adminUsername,
    required String adminPin,
    required String planCode,
    required String licenseDuration,
    required int maxDevices,
    required int maxUsers,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse(normalizeBaseUrl(baseUrl) + '/tenants'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({
        'company_name': companyName.trim(),
        'cloud_base_url':
            cloudBaseUrl == null || cloudBaseUrl.trim().isEmpty
                ? null
                : normalizeBaseUrl(cloudBaseUrl),
        'owner_name': ownerName.trim().isEmpty ? null : ownerName.trim(),
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'address': address.trim().isEmpty ? null : address.trim(),
        'branch_name': branchName.trim(),
        'admin_full_name': adminFullName.trim(),
        'admin_username': adminUsername.trim(),
        'admin_pin': adminPin.trim(),
        'plan_code': planCode.trim(),
        'license_duration': licenseDuration.trim(),
        'max_devices': maxDevices,
        'max_users': maxUsers,
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudTenantCreateResponse.fromJson(json);
  }

  Future<KeseCloudCreatorAuthResponse> creatorAuth({
    required String baseUrl,
    required String username,
    required String pin,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/auth'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'username': username.trim(),
        'pin': pin.trim(),
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudCreatorAuthResponse.fromJson(json);
  }

  Future<KeseCloudCreatorTenantsResponse> creatorTenants({
    required String baseUrl,
    required String accessToken,
  }) async {
    final response = await _send(
      _client.get(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/tenants'),
      headers: _authHeaders(accessToken),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudCreatorTenantsResponse.fromJson(json);
  }

  Future<KeseCloudCreatorAuthResponse> creatorUpdateProfile({
    required String baseUrl,
    required String accessToken,
    required String currentPin,
    required String username,
    required String pin,
  }) async {
    final response = await _send(
      _client.put(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/profile'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({
        'current_pin': currentPin.trim(),
        'username': username.trim(),
        'pin': pin.trim(),
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudCreatorAuthResponse.fromJson(json);
  }

  Future<KeseCloudLicense> creatorUpdateLicense({
    required String baseUrl,
    required String accessToken,
    required int licenseId,
    String? licenseCode,
    String? status,
    String? planCode,
    String? licenseDuration,
    int? maxDevices,
    int? maxUsers,
    String? cloudBaseUrl,
  }) async {
    final response = await _send(
      _client.patch(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/licenses/$licenseId'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({
        if (licenseCode != null) 'license_code': normalizeLicenseCode(licenseCode),
        if (status != null) 'status': status,
        if (planCode != null) 'plan_code': planCode,
        if (licenseDuration != null) 'license_duration': licenseDuration,
        if (maxDevices != null) 'max_devices': maxDevices,
        if (maxUsers != null) 'max_users': maxUsers,
        if (cloudBaseUrl != null)
          'cloud_base_url': cloudBaseUrl.trim().isEmpty
              ? null
              : normalizeBaseUrl(cloudBaseUrl),
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudLicense.fromJson(json);
  }

  Future<KeseCloudLicense> creatorResetLicense({
    required String baseUrl,
    required String accessToken,
    required int licenseId,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/licenses/$licenseId/reset'),
      headers: _authHeaders(accessToken),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudLicense.fromJson(
      (json['license'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }

  Future<void> creatorDeleteLicense({
    required String baseUrl,
    required String accessToken,
    required int licenseId,
  }) async {
    final response = await _send(
      _client.delete(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/creator/licenses/$licenseId'),
      headers: _authHeaders(accessToken),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
  }

  Future<KeseCloudAuthResponse> login({
    required String baseUrl,
    required String tenantKey,
    required String username,
    required String pin,
    required String deviceUuid,
    required String deviceLabel,
    required String platformName,
    required String appVersion,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'tenant_key': tenantKey.trim().toLowerCase(),
        'username': username.trim(),
        'pin': pin.trim(),
        'device_uuid': deviceUuid.trim(),
        'device_label': deviceLabel.trim(),
        'platform_name': platformName.trim(),
        'app_version': appVersion.trim(),
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudAuthResponse.fromJson(json);
  }

  Future<KeseCloudBootstrapResponse> bootstrap({
    required String baseUrl,
    required String accessToken,
  }) async {
    final response = await _send(
      _client.get(
      Uri.parse('${normalizeBaseUrl(baseUrl)}/bootstrap'),
      headers: _authHeaders(accessToken),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudBootstrapResponse.fromJson(json);
  }

  Future<KeseCloudPushResponse> push({
    required KeseCloudSession session,
    required List<Map<String, dynamic>> operations,
  }) async {
    final response = await _send(
      _client.post(
      Uri.parse('${normalizeBaseUrl(session.baseUrl)}/sync/push'),
      headers: _authHeaders(session.accessToken),
      body: jsonEncode({
        'device_uuid': session.deviceUuid,
        'operations': operations,
      }),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudPushResponse.fromJson(json);
  }

  Future<KeseCloudPullResponse> pull({
    required KeseCloudSession session,
    required int afterId,
    int limit = 250,
  }) async {
    final uri = Uri.parse(
      '${normalizeBaseUrl(session.baseUrl)}/sync/pull?after_id=$afterId&limit=$limit',
    );
    final response = await _send(
      _client.get(
        uri,
        headers: _authHeaders(session.accessToken),
      ),
    );
    final json = _decodeMap(response);
    _throwIfNeeded(response, json);
    return KeseCloudPullResponse.fromJson(json);
  }

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
      };

  Map<String, String> _authHeaders(String token) => {
        ..._jsonHeaders,
        'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _decodeMap(http.Response response) {
    final text = utf8.decode(response.bodyBytes, allowMalformed: false);
    if (text.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  void _throwIfNeeded(http.Response response, Map<String, dynamic> json) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final detail = json['detail'];
    final message = detail is String
        ? detail
        : 'La connexion cloud a échoué. Code ${response.statusCode}.';
    throw KeseCloudException(message, statusCode: response.statusCode);
  }
}



