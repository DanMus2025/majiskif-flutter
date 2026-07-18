import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:majiskif/core/app_controller.dart';
import 'package:majiskif/core/models.dart';
import 'package:majiskif/core/store_interface.dart';

class FakeAppStore implements AppStore {
  FakeAppStore();

  final Map<String, String> _kv = <String, String>{};
  final Map<String, List<RecordEnvelope>> _records = <String, List<RecordEnvelope>>{};
  final List<ChangeEnvelope> _changes = <ChangeEnvelope>[];
  String _tenantKey = 'system';
  int _revision = 0;

  @override
  String get tenantKey => _tenantKey;

  @override
  Future<void> init(String tenantKey) async {
    _tenantKey = tenantKey;
  }

  @override
  Future<void> clearAll() async {
    _kv.clear();
    _records.clear();
    _changes.clear();
    _revision = 0;
  }

  @override
  Future<RecordEnvelope?> getRecord(String type, String entityId) async {
    final items = _records[type] ?? const <RecordEnvelope>[];
    for (final item in items.reversed) {
      if (item.entityId == entityId && item.tenantKey == _tenantKey && !item.deleted) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<String?> getValue(String key) async => _kv[key];

  @override
  Future<int> getRevision() async => _revision;

  @override
  Future<void> markChangesSynced(List<int> ids) async {
    for (var i = 0; i < _changes.length; i++) {
      if (ids.contains(_changes[i].id)) {
        _changes[i] = ChangeEnvelope(
          id: _changes[i].id,
          operation: _changes[i].operation,
          record: _changes[i].record,
          createdAt: _changes[i].createdAt,
          synced: true,
        );
      }
    }
  }

  @override
  Future<void> markDeleted(String type, String entityId, {bool queueChange = true}) async {
    final record = _records[type] ?? <RecordEnvelope>[];
    final index = record.indexWhere((item) => item.entityId == entityId && item.tenantKey == _tenantKey);
    if (index >= 0) {
      record[index] = record[index].copyWith(deleted: true);
    }
    if (queueChange) {
      _changes.add(ChangeEnvelope(
        id: _changes.length + 1,
        operation: 'delete',
        record: RecordEnvelope(
          id: '$type:$entityId',
          type: type,
          entityId: entityId,
          tenantKey: _tenantKey,
          payload: <String, dynamic>{},
          updatedAt: DateTime.now().toUtc(),
          revision: _revision + 1,
          deleted: true,
        ),
        createdAt: DateTime.now().toUtc(),
        synced: false,
      ));
    }
  }

  @override
  Future<List<ChangeEnvelope>> pendingChanges() async {
    return _changes.where((change) => change.record.tenantKey == _tenantKey && !change.synced).toList(growable: false);
  }

  @override
  Future<int> nextRevision() async {
    _revision += 1;
    return _revision;
  }

  @override
  Future<void> removeValue(String key) async {
    _kv.remove(key);
  }

  @override
  Future<void> setRevision(int revision) async {
    _revision = revision;
  }

  @override
  Future<void> setValue(String key, String value) async {
    _kv[key] = value;
  }

  @override
  Future<List<RecordEnvelope>> listRecords({String? type, bool includeDeleted = false}) async {
    final results = <RecordEnvelope>[];
    for (final entry in _records.entries) {
      if (type != null && entry.key != type) continue;
      results.addAll(entry.value.where((item) => item.tenantKey == _tenantKey && (includeDeleted || !item.deleted)));
    }
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  @override
  Future<void> upsertRecord(
    String type,
    String entityId,
    Map<String, dynamic> payload, {
    bool deleted = false,
    bool queueChange = true,
    String operation = 'upsert',
    int? revisionOverride,
  }) async {
    final revision = revisionOverride ?? (_revision + 1);
    _revision = revision;
    final record = RecordEnvelope(
      id: '$type:$entityId',
      type: type,
      entityId: entityId,
      tenantKey: _tenantKey,
      payload: payload,
      updatedAt: DateTime.now().toUtc(),
      revision: revision,
      deleted: deleted,
    );
    final list = _records.putIfAbsent(type, () => <RecordEnvelope>[]);
    list.removeWhere((item) => item.entityId == entityId && item.tenantKey == _tenantKey);
    list.add(record);
    if (queueChange) {
      _changes.add(ChangeEnvelope(
        id: _changes.length + 1,
        operation: operation,
        record: record,
        createdAt: DateTime.now().toUtc(),
        synced: false,
      ));
    }
  }
}

void main() {
  test('purchase total is calculated automatically and status updates', () async {
    final store = FakeAppStore();
    final controller = AppController(store: store);
    await store.init('system');
    await controller.activateLicense(licenseKey: 'LIC-123', ownerName: 'Client');
    await controller.createInitialAdmin(name: 'Admin', email: 'admin@test.local', password: 'secret1');
    await controller.addOrUpdateProduct(
      name: 'Produit A',
      sku: 'PA',
      unitPrice: 120,
      costPrice: 80,
      stockQuantity: 10,
    );

    final product = controller.products.value.first;
    await controller.recordPurchase(
      supplierId: 'sup-1',
      supplierName: 'Fournisseur 1',
      lines: [PurchaseLineItem(productId: product.id, label: product.name, quantity: 2, unitPrice: 50)],
      paidAmount: 25,
      dueAt: DateTime.now().toUtc().add(const Duration(days: 30)),
    );

    expect(controller.purchases.value.single.totalAmount, 100);
    expect(controller.purchases.value.single.remainingAmount, 75);
    expect(controller.purchases.value.single.paymentStatus, PurchasePaymentStatus.partial);
  });

  test('sales and purchases update dashboard coherently', () async {
    final store = FakeAppStore();
    final controller = AppController(store: store);
    await store.init('system');
    await controller.activateLicense(licenseKey: 'LIC-456', ownerName: 'Client');
    await controller.createInitialAdmin(name: 'Admin', email: 'admin@test.local', password: 'secret1');
    await controller.addOrUpdateProduct(
      name: 'Produit B',
      sku: 'PB',
      unitPrice: 200,
      costPrice: 120,
      stockQuantity: 10,
    );

    final product = controller.products.value.first;
    await controller.recordPurchase(
      supplierId: 'sup-1',
      supplierName: 'Fournisseur',
      lines: [PurchaseLineItem(productId: product.id, label: product.name, quantity: 2, unitPrice: 100)],
      paidAmount: 200,
      dueAt: null,
    );
    await controller.recordSale(
      customerId: 'cus-1',
      customerName: 'Client',
      lines: [SaleLineItem(productId: product.id, label: product.name, quantity: 1, unitPrice: 180)],
    );

    expect(controller.sales.value.single.totalAmount, 180);
    expect(controller.dashboard.value.totalSales, 180);
    expect(controller.dashboard.value.totalPurchases, 200);
    expect(controller.products.value.single.stockQuantity, 11);
  });

  test('license state is stored locally and restored', () async {
    final store = FakeAppStore();
    final controller = AppController(store: store);
    await store.init('system');
    await controller.activateLicense(licenseKey: 'LIC-789', ownerName: 'Client');
    final raw = await store.getValue('license_state');
    expect(raw, isNotNull);

    final restored = LicenseState.fromMap(jsonDecode(raw!) as Map<String, dynamic>);
    expect(restored.licenseKey, 'LIC-789');
    expect(restored.isValid, isTrue);
  });
}

