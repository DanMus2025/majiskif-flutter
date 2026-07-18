import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'local_store_service.dart';

class _IoLocalStoreService implements LocalStoreService {
  Object? _database;

  static const List<String> _schemaStatements = [
    '''
CREATE TABLE IF NOT EXISTS app_meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS tenants (
  tenant_id TEXT PRIMARY KEY,
  company_name TEXT NOT NULL,
  owner_name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  logo_url TEXT,
  rccm TEXT,
  id_nat TEXT,
  nif TEXT,
  efo TEXT,
  currency_code TEXT NOT NULL DEFAULT 'FC',
  tax_rate NUMERIC NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS branches (
  branch_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_name TEXT NOT NULL,
  is_main_branch INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS devices (
  device_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_label TEXT NOT NULL,
  platform_name TEXT NOT NULL,
  last_seen_at TEXT,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS app_users (
  user_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  username TEXT NOT NULL,
  username_normalized TEXT NOT NULL,
  role_name TEXT NOT NULL,
  pin_hash TEXT NOT NULL,
  is_blocked INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (tenant_id, username_normalized)
)
''',
    '''
CREATE TABLE IF NOT EXISTS categories (
  category_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  category_name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE (tenant_id, category_name)
)
''',
    '''
CREATE TABLE IF NOT EXISTS products (
  product_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  category_id TEXT,
  sku TEXT NOT NULL,
  barcode TEXT NOT NULL,
  product_name TEXT NOT NULL,
  unit_name TEXT NOT NULL,
  cost_amount NUMERIC NOT NULL DEFAULT 0,
  price_amount NUMERIC NOT NULL DEFAULT 0,
  quantity_on_hand NUMERIC NOT NULL DEFAULT 0,
  min_quantity NUMERIC NOT NULL DEFAULT 0,
  location_label TEXT,
  image_url TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (tenant_id, sku),
  UNIQUE (tenant_id, barcode)
)
''',
    '''
CREATE TABLE IF NOT EXISTS customers (
  customer_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS suppliers (
  supplier_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  supplier_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS sales (
  sale_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  order_no TEXT NOT NULL,
  invoice_no TEXT NOT NULL,
  ticket_no TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  subtotal_amount NUMERIC NOT NULL DEFAULT 0,
  discount_amount NUMERIC NOT NULL DEFAULT 0,
  total_amount NUMERIC NOT NULL DEFAULT 0,
  paid_amount NUMERIC NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL,
  due_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (tenant_id, invoice_no),
  UNIQUE (tenant_id, ticket_no),
  UNIQUE (tenant_id, order_no)
)
''',
    '''
CREATE TABLE IF NOT EXISTS sale_lines (
  sale_line_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  sale_id TEXT NOT NULL,
  product_id TEXT,
  product_name TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  unit_price NUMERIC NOT NULL,
  unit_cost NUMERIC NOT NULL,
  line_total NUMERIC NOT NULL,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS purchases (
  purchase_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  reference_no TEXT NOT NULL,
  product_name TEXT NOT NULL,
  supplier_name TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  total_amount NUMERIC NOT NULL,
  paid_amount NUMERIC NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (tenant_id, reference_no)
)
''',
    '''
CREATE TABLE IF NOT EXISTS expenses (
  expense_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  label TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS stock_moves (
  move_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  move_type TEXT NOT NULL,
  product_name TEXT NOT NULL,
  quantity_delta NUMERIC NOT NULL,
  reference_no TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS app_messages (
  message_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  sender_user_id TEXT,
  sender_name TEXT,
  recipient_user_id TEXT,
  recipient_name TEXT,
  message_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  read_at TEXT,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS app_alerts (
  alert_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  level_name TEXT NOT NULL,
  read_at TEXT,
  created_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS sync_queue (
  queue_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  entity_name TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation_name TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  payload_hash TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS sync_conflicts (
  conflict_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  entity_name TEXT NOT NULL,
  local_entity_id TEXT NOT NULL,
  server_entity_id TEXT,
  conflict_type TEXT NOT NULL,
  local_payload_json TEXT NOT NULL,
  server_payload_json TEXT,
  resolution_status TEXT NOT NULL DEFAULT 'open',
  created_at TEXT NOT NULL,
  resolved_at TEXT
)
''',
  ];

  static const List<String> _normalizedTables = [
    'tenants',
    'branches',
    'devices',
    'app_users',
    'categories',
    'products',
    'customers',
    'suppliers',
    'sales',
    'sale_lines',
    'purchases',
    'expenses',
    'stock_moves',
    'app_messages',
    'app_alerts',
    'sync_queue',
    'sync_conflicts',
  ];

  Future<dynamic> _openDb() async {
    if (_database != null) return _database;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      final dir = await getApplicationSupportDirectory();
      final dbPath = p.join(dir.path, 'kese_local.db');
      _database = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async => _ensureSchema(db),
          onOpen: (db) async => _ensureSchema(db),
          onUpgrade: (db, oldVersion, newVersion) async => _ensureSchema(db),
        ),
      );
      return _database;
    }

    final dbPath = p.join(await sqflite.getDatabasesPath(), 'kese_local.db');
    _database = await sqflite.openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async => _ensureSchema(db),
      onOpen: (db) async => _ensureSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async => _ensureSchema(db),
    );
    return _database;
  }

  Future<void> _ensureSchema(dynamic db) async {
    await db.execute("PRAGMA encoding = 'UTF-8'");
    for (final statement in _schemaStatements) {
      await db.execute(statement);
    }
  }

  @override
  Future<String?> loadSnapshotJson() async {
    final db = await _openDb();
    final rows = await db.query(
      'app_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['app_store_snapshot'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  @override
  Future<void> saveSnapshotJson(String json) async {
    final db = await _openDb();
    await db.insert(
      'app_meta',
      {'key': 'app_store_snapshot', 'value': json},
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    try {
      await db.transaction((txn) async {
        await _persistNormalizedSnapshot(txn, json);
      });
    } catch (_) {
      // The serialized snapshot is the authoritative local state used on
      // relaunch. A failure in the normalized mirror must never drop the
      // authenticated session or the local working data.
    }
  }

  Future<void> _persistNormalizedSnapshot(dynamic txn, String json) async {
    final snapshot = _normalizeMap(jsonDecode(json));
    final tenantId = _string(snapshot['tenantId']);
    final branchId = _string(snapshot['branchId']);
    final deviceId = _string(snapshot['deviceId']);
    final exportedAt = _string(snapshot['lastSyncAt']).isNotEmpty
        ? _string(snapshot['lastSyncAt'])
        : DateTime.now().toIso8601String();

    for (final table in _normalizedTables.reversed) {
      await txn.delete(table);
    }

    final settings = _normalizeMap(snapshot['settings']);
    await txn.insert('tenants', {
      'tenant_id': tenantId,
      'company_name': _string(settings['companyName'], 'Votre entreprise'),
      'owner_name': _string(settings['ownerName']),
      'phone': _string(settings['phone']),
      'email': _string(settings['email']),
      'address': _string(settings['address']),
      'logo_url': _string(settings['logoUrl']),
      'rccm': _string(settings['rccm']),
      'id_nat': _string(settings['idNat']),
      'nif': _string(settings['nif']),
      'efo': _string(settings['efo']),
      'currency_code': _string(settings['currency'], 'FC'),
      'tax_rate': _num(settings['taxRate']),
      'created_at': exportedAt,
      'updated_at': exportedAt,
    });

    await txn.insert('branches', {
      'branch_id': branchId,
      'tenant_id': tenantId,
      'branch_name': 'Site principal',
      'is_main_branch': 1,
      'created_at': exportedAt,
      'updated_at': exportedAt,
    });

    await txn.insert('devices', {
      'device_id': deviceId,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'device_label': Platform.localHostname,
      'platform_name': Platform.operatingSystem,
      'last_seen_at': DateTime.now().toIso8601String(),
      'created_at': exportedAt,
    });

    final categories = _list(snapshot['categories']);
    for (final category in categories) {
      final categoryName = _string(category);
      if (categoryName.isEmpty) continue;
      await txn.insert('categories', {
        'category_id': '$tenantId::$categoryName',
        'tenant_id': tenantId,
        'category_name': categoryName,
        'created_at': exportedAt,
      });
    }

    for (final user in _listOfMaps(snapshot['users'])) {
      final username = _string(user['username']);
      await txn.insert('app_users', {
        'user_id': _string(user['code']),
        'tenant_id': tenantId,
        'branch_id': branchId,
        'full_name': _string(user['name']),
        'username': username,
        'username_normalized': username.trim().toLowerCase(),
        'role_name': _string(user['role']),
        'pin_hash': _string(user['pin']),
        'is_blocked': _boolInt(user['isBlocked']),
        'created_at': exportedAt,
        'updated_at': exportedAt,
      });
    }

    for (final customer in _listOfMaps(snapshot['customers'])) {
      await txn.insert('customers', {
        'customer_id': _string(customer['code']),
        'tenant_id': tenantId,
        'full_name': _string(customer['name']),
        'phone': _string(customer['phone']),
        'address': _string(customer['address']),
        'created_at': exportedAt,
        'updated_at': exportedAt,
      });
    }

    for (final supplier in _listOfMaps(snapshot['suppliers'])) {
      await txn.insert('suppliers', {
        'supplier_id': _string(supplier['code']),
        'tenant_id': tenantId,
        'supplier_name': _string(supplier['name']),
        'phone': _string(supplier['phone']),
        'address': _string(supplier['address']),
        'created_at': exportedAt,
        'updated_at': exportedAt,
      });
    }

    final productByName = <String, String>{};
    for (final product in _listOfMaps(snapshot['products'])) {
      final categoryName = _string(product['category']);
      final productId = _string(product['code']);
      final productName = _string(product['name']);
      productByName[productName] = productId;
      await txn.insert('products', {
        'product_id': productId,
        'tenant_id': tenantId,
        'branch_id': branchId,
        'category_id': categoryName.isEmpty ? null : '$tenantId::$categoryName',
        'sku': _string(product['sku']),
        'barcode': _string(product['barcode']),
        'product_name': productName,
        'unit_name': _string(product['unit'], 'piece'),
        'cost_amount': _num(product['cost']),
        'price_amount': _num(product['price']),
        'quantity_on_hand': _num(product['quantity']),
        'min_quantity': _num(product['minQuantity']),
        'location_label': _string(product['location']),
        'image_url': _string(product['imageUrl']),
        'created_at': exportedAt,
        'updated_at': exportedAt,
      });
    }

    for (final purchase in _listOfMaps(snapshot['purchases'])) {
      await txn.insert('purchases', {
        'purchase_id': _string(purchase['reference']),
        'tenant_id': tenantId,
        'branch_id': branchId,
        'reference_no': _string(purchase['reference']),
        'product_name': _string(purchase['product']),
        'supplier_name': _string(purchase['supplier']),
        'quantity': _num(purchase['quantity']),
        'total_amount': _num(purchase['total']),
        'paid_amount': _num(purchase['paid']),
        'created_at': _string(purchase['createdAt'], exportedAt),
        'updated_at': _string(purchase['createdAt'], exportedAt),
      });
    }

    for (final expense in _listOfMaps(snapshot['expenses'])) {
      await txn.insert('expenses', {
        'expense_id': '${tenantId}::expense::${_string(expense['createdAt'])}::${_string(expense['label'])}',
        'tenant_id': tenantId,
        'branch_id': branchId,
        'label': _string(expense['label']),
        'amount': _num(expense['amount']),
        'created_at': _string(expense['createdAt'], exportedAt),
      });
    }

    for (final move in _listOfMaps(snapshot['stockMoves'])) {
      await txn.insert('stock_moves', {
        'move_id': '${tenantId}::move::${_string(move['createdAt'])}::${_string(move['reference'])}::${_string(move['product'])}',
        'tenant_id': tenantId,
        'branch_id': branchId,
        'move_type': _string(move['type']),
        'product_name': _string(move['product']),
        'quantity_delta': _num(move['quantity']),
        'reference_no': _string(move['reference']),
        'created_at': _string(move['createdAt'], exportedAt),
      });
    }

    for (final sale in _listOfMaps(snapshot['sales'])) {
      final saleId = _string(sale['invoiceNo']);
      await txn.insert('sales', {
        'sale_id': saleId,
        'tenant_id': tenantId,
        'branch_id': branchId,
        'order_no': _string(sale['orderNo']),
        'invoice_no': saleId,
        'ticket_no': _string(sale['ticketNo']),
        'customer_id': _string(sale['customerCode']),
        'cashier_id': _string(sale['cashierCode']),
        'subtotal_amount': _num(sale['subtotal']),
        'discount_amount': _num(sale['discount']),
        'total_amount': _num(sale['total']),
        'paid_amount': _num(sale['paid']),
        'payment_method': _string(sale['method']),
        'due_date': _string(sale['dueDate'], exportedAt),
        'created_at': _string(sale['createdAt'], exportedAt),
        'updated_at': _string(sale['createdAt'], exportedAt),
      });

      final lines = _listOfMaps(sale['lines']);
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        final productName = _string(line['product']);
        await txn.insert('sale_lines', {
          'sale_line_id': '$saleId::line::$index',
          'tenant_id': tenantId,
          'sale_id': saleId,
          'product_id': productByName[productName],
          'product_name': productName,
          'quantity': _num(line['qty']),
          'unit_price': _num(line['price']),
          'unit_cost': _num(line['cost']),
          'line_total': _num(line['qty']) * _num(line['price']),
          'created_at': _string(sale['createdAt'], exportedAt),
        });
      }
    }

    for (final alert in _listOfMaps(snapshot['alerts'])) {
      await txn.insert('app_alerts', {
        'alert_id': _string(alert['id']),
        'tenant_id': tenantId,
        'title': _string(alert['title']),
        'body': _string(alert['body']),
        'level_name': _string(alert['level'], 'info'),
        'read_at': _nullableString(alert['readAt']),
        'created_at': _string(alert['createdAt'], exportedAt),
      });
    }

    for (final message in _listOfMaps(snapshot['messages'])) {
      await txn.insert('app_messages', {
        'message_id': _string(message['id']),
        'tenant_id': tenantId,
        'sender_user_id': _nullableString(message['senderCode']),
        'sender_name': _nullableString(message['senderName']),
        'recipient_user_id': _nullableString(message['recipientCode']),
        'recipient_name': _nullableString(message['recipientName']),
        'message_type': _string(message['type'], 'system'),
        'title': _string(message['title']),
        'body': _string(message['body']),
        'read_at': _nullableString(message['readAt']),
        'created_at': _string(message['createdAt'], exportedAt),
      });
    }

    for (final entry in _listOfMaps(snapshot['syncQueue'])) {
      await txn.insert('sync_queue', {
        'queue_id': _string(entry['id']),
        'tenant_id': _string(entry['tenantId'], tenantId),
        'branch_id': _string(entry['branchId'], branchId),
        'device_id': _string(entry['deviceId'], deviceId),
        'entity_name': _string(entry['entityName']),
        'entity_id': _string(entry['entityId']),
        'operation_name': _string(entry['operationName']),
        'payload_json': _string(entry['payloadJson'], '{}'),
        'payload_hash': _string(entry['payloadHash']),
        'sync_status': _string(entry['status'], 'pending'),
        'retry_count': _int(entry['retryCount']),
        'last_error': _nullableString(entry['lastError']),
        'created_at': _string(entry['createdAt'], exportedAt),
        'updated_at': _string(entry['updatedAt'], exportedAt),
      });
    }

    for (final entry in _listOfMaps(snapshot['syncConflicts'])) {
      await txn.insert('sync_conflicts', {
        'conflict_id': _string(entry['id']),
        'tenant_id': _string(entry['tenantId'], tenantId),
        'branch_id': _string(entry['branchId'], branchId),
        'device_id': _string(entry['deviceId'], deviceId),
        'entity_name': _string(entry['entityName']),
        'local_entity_id': _string(entry['localEntityId']),
        'server_entity_id': _nullableString(entry['serverEntityId']),
        'conflict_type': _string(entry['conflictType']),
        'local_payload_json': _string(entry['localPayloadJson'], '{}'),
        'server_payload_json': _nullableString(entry['serverPayloadJson']),
        'resolution_status': _string(entry['resolutionStatus'], 'open'),
        'created_at': _string(entry['createdAt'], exportedAt),
        'resolved_at': _nullableString(entry['resolvedAt']),
      });
    }
  }

  Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return <String, dynamic>{};
  }

  List<dynamic> _list(dynamic value) => value is List ? value : const [];

  List<Map<String, dynamic>> _listOfMaps(dynamic value) => _list(value)
      .whereType<Map>()
      .map((entry) => entry.map((key, val) => MapEntry('$key', val)))
      .toList();

  String _string(dynamic value, [String fallback = '']) =>
      value == null ? fallback : '$value';

  String? _nullableString(dynamic value) {
    final normalized = _string(value);
    return normalized.isEmpty ? null : normalized;
  }

  num _num(dynamic value, [num fallback = 0]) {
    if (value is num) return value;
    return num.tryParse('${value ?? ''}') ?? fallback;
  }

  int _int(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse('${value ?? ''}') ?? fallback;
  }

  int _boolInt(dynamic value) {
    if (value is bool) return value ? 1 : 0;
    final text = _string(value).toLowerCase();
    return text == 'true' || text == '1' ? 1 : 0;
  }
}

LocalStoreService createLocalStoreServiceImpl() => _IoLocalStoreService();
