import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'backend_api.dart';
import 'models.dart';
import 'store.dart';

enum AppPhase { loading, needLicense, needSetup, needLogin, ready }

class AppController extends ChangeNotifier {
  AppController({AppStore? store, CloudApi? api, String? cloudBaseUrl})
    : _store = store ?? createAppStore(),
      _api = api,
      _cloudBaseUrl =
          cloudBaseUrl ??
          const String.fromEnvironment('KESE_CLOUD_BASE_URL', defaultValue: '');

  final AppStore _store;
  final CloudApi? _api;
  final String _cloudBaseUrl;

  final ValueNotifier<AppPhase> phase = ValueNotifier<AppPhase>(
    AppPhase.loading,
  );
  final ValueNotifier<LicenseState?> license = ValueNotifier<LicenseState?>(
    null,
  );
  final ValueNotifier<AppSession?> session = ValueNotifier<AppSession?>(null);
  final ValueNotifier<bool> syncing = ValueNotifier<bool>(false);
  final ValueNotifier<String?> syncMessage = ValueNotifier<String?>(null);
  final ValueNotifier<DashboardSnapshot> dashboard =
      ValueNotifier<DashboardSnapshot>(DashboardSnapshot.empty());
  final ValueNotifier<List<ProductItem>> products =
      ValueNotifier<List<ProductItem>>(const <ProductItem>[]);
  final ValueNotifier<List<CustomerItem>> customers =
      ValueNotifier<List<CustomerItem>>(const <CustomerItem>[]);
  final ValueNotifier<List<SupplierItem>> suppliers =
      ValueNotifier<List<SupplierItem>>(const <SupplierItem>[]);
  final ValueNotifier<List<SaleItem>> sales = ValueNotifier<List<SaleItem>>(
    const <SaleItem>[],
  );
  final ValueNotifier<List<PurchaseItem>> purchases =
      ValueNotifier<List<PurchaseItem>>(const <PurchaseItem>[]);
  final ValueNotifier<List<PurchasePaymentItem>> purchasePayments =
      ValueNotifier<List<PurchasePaymentItem>>(const <PurchasePaymentItem>[]);
  final ValueNotifier<List<ExpenseItem>> expenses =
      ValueNotifier<List<ExpenseItem>>(const <ExpenseItem>[]);
  final ValueNotifier<List<AppUser>> users = ValueNotifier<List<AppUser>>(
    const <AppUser>[],
  );

  Timer? _syncTimer;
  String _deviceId = '';
  String? _serverRevision;

  bool get hasApi => _api != null || _cloudBaseUrl.isNotEmpty;
  CloudApi? get _cloudApi =>
      _api ??
      (_cloudBaseUrl.isEmpty
          ? null
          : CloudApi(
              Uri.parse(
                _cloudBaseUrl.endsWith('/') ? _cloudBaseUrl : '$_cloudBaseUrl/',
              ),
            ));

  Future<void> bootstrap() async {
    phase.value = AppPhase.loading;
    await _store.init('system');
    _deviceId = await _ensureDeviceId();
    _serverRevision = await _store.getValue('server_revision');
    await _restoreLicense();
    if (license.value == null) {
      phase.value = AppPhase.needLicense;
      return;
    }
    if (license.value!.isExpired || !license.value!.isValid) {
      phase.value = AppPhase.needLicense;
      return;
    }
    await _switchToBusinessTenant(license.value!);
    await _loadAll();
    if (users.value.isEmpty) {
      phase.value = AppPhase.needSetup;
    } else {
      await _restoreSession();
      phase.value = session.value == null ? AppPhase.needLogin : AppPhase.ready;
    }
    _startSyncLoop();
    unawaited(_validateLicenseInBackground());
  }

  Future<void> activateLicense({
    required String licenseKey,
    required String ownerName,
  }) async {
    final normalizedKey = licenseKey.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError('License key required');
    }
    final tenantKey = _tenantKeyFromLicense(normalizedKey);
    final now = DateTime.now().toUtc();
    final state = LicenseState(
      licenseKey: normalizedKey,
      tenantKey: tenantKey,
      ownerName: ownerName.trim().isEmpty ? 'Client' : ownerName.trim(),
      deviceId: _deviceId,
      activatedAt: now,
      updatedAt: now,
      status: 'valid',
      lastValidatedAt: now,
    );
    await _store.setValue('license_state', encodeJson(state.toMap()));
    license.value = state;
    await _switchToBusinessTenant(state);
    await _loadAll();
    phase.value = users.value.isEmpty ? AppPhase.needSetup : AppPhase.needLogin;
    _startSyncLoop();
    unawaited(_validateLicenseInBackground());
  }

  Future<void> invalidateLicense() async {
    await _store.removeValue('license_state');
    await _store.removeValue('server_revision');
    license.value = null;
    session.value = null;
    _serverRevision = null;
    await _store.init('system');
    phase.value = AppPhase.needLicense;
    _stopSyncLoop();
  }

  Future<void> createInitialAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: newId('user'),
      name: name.trim().isEmpty ? 'Administrateur' : name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: _hashPassword(password),
      role: 'admin',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _store.upsertRecord('user', user.id, user.toMap());
    await _loadUsers();
    await signIn(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    final normalized = email.trim().toLowerCase();
    final hashed = _hashPassword(password);
    final existing = users.value
        .where(
          (user) =>
              user.email.toLowerCase() == normalized &&
              user.passwordHash == hashed,
        )
        .toList(growable: false);
    if (existing.isEmpty) {
      throw StateError('Identifiants invalides');
    }
    final active = AppSession(
      user: existing.first,
      startedAt: DateTime.now().toUtc(),
    );
    session.value = active;
    await _store.setValue('session', encodeJson(active.toMap()));
    phase.value = AppPhase.ready;
  }

  Future<void> signOut() async {
    session.value = null;
    await _store.removeValue('session');
    if (license.value == null || !license.value!.isValid) {
      phase.value = AppPhase.needLicense;
    } else if (users.value.isEmpty) {
      phase.value = AppPhase.needSetup;
    } else {
      phase.value = AppPhase.needLogin;
    }
  }

  Future<void> addOrUpdateProduct({
    String? id,
    required String name,
    required String sku,
    required double unitPrice,
    required double costPrice,
    required double stockQuantity,
  }) async {
    final now = DateTime.now().toUtc();
    final productId = id ?? newId('product');
    final payload = <String, dynamic>{
      'id': productId,
      'name': name.trim(),
      'sku': sku.trim(),
      'unitPrice': unitPrice,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _store.upsertRecord('product', productId, payload);
    await _loadProducts();
    await _refreshDashboard();
  }

  Future<void> addOrUpdateCustomer({
    String? id,
    required String name,
    required String phone,
  }) async {
    final now = DateTime.now().toUtc();
    final customerId = id ?? newId('customer');
    final payload = <String, dynamic>{
      'id': customerId,
      'name': name.trim(),
      'phone': phone.trim(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _store.upsertRecord('customer', customerId, payload);
    await _loadCustomers();
  }

  Future<void> addOrUpdateSupplier({
    String? id,
    required String name,
    required String phone,
  }) async {
    final now = DateTime.now().toUtc();
    final supplierId = id ?? newId('supplier');
    final payload = <String, dynamic>{
      'id': supplierId,
      'name': name.trim(),
      'phone': phone.trim(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _store.upsertRecord('supplier', supplierId, payload);
    await _loadSuppliers();
  }

  Future<void> recordExpense({
    String? id,
    required String label,
    required double amount,
  }) async {
    final now = DateTime.now().toUtc();
    final expenseId = id ?? newId('expense');
    final payload = <String, dynamic>{
      'id': expenseId,
      'label': label.trim(),
      'amount': amount,
      'createdAt': now.toIso8601String(),
    };
    await _store.upsertRecord('expense', expenseId, payload);
    await _loadExpenses();
    await _refreshDashboard();
  }

  Future<void> recordSale({
    String? id,
    required String customerId,
    required String customerName,
    required List<SaleLineItem> lines,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('At least one sale line is required');
    }
    final now = DateTime.now().toUtc();
    final saleId = id ?? newId('sale');
    final totalAmount = lines.fold<double>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    var costAmount = 0.0;
    final productMap = _productPayloadMap();
    final updatedProducts = <ProductItem>[];
    for (final line in lines) {
      final payload = productMap[line.productId];
      if (payload == null) {
        continue;
      }
      final product = ProductItem.fromMap(payload);
      final productCost = asDouble(payload['costPrice']);
      final effectiveCost = productCost > 0
          ? productCost
          : (line.unitPrice * 0.7);
      costAmount += effectiveCost * line.quantity;
      final updatedStock = (product.stockQuantity - line.quantity).clamp(
        0,
        double.infinity,
      );
      final nextPayload = <String, dynamic>{
        ...payload,
        'stockQuantity': updatedStock,
        'updatedAt': now.toIso8601String(),
      };
      updatedProducts.add(ProductItem.fromMap(nextPayload));
      await _store.upsertRecord('product', product.id, nextPayload);
      await _store
          .upsertRecord('stock_movement', newId('stock'), <String, dynamic>{
            'id': newId('stock'),
            'productId': product.id,
            'label': product.name,
            'direction': 'out',
            'quantity': line.quantity,
            'unitPrice': line.unitPrice,
            'costPrice': effectiveCost,
            'createdAt': now.toIso8601String(),
            'sourceId': saleId,
            'sourceType': 'sale',
          });
    }
    final profitAmount = totalAmount - costAmount;
    final payload = <String, dynamic>{
      'id': saleId,
      'customerId': customerId,
      'customerName': customerName.trim(),
      'lines': lines.map((line) => line.toMap()).toList(growable: false),
      'totalAmount': totalAmount,
      'costAmount': costAmount,
      'profitAmount': profitAmount,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _store.upsertRecord('sale', saleId, payload);
    await _loadSales();
    await _loadProducts();
    await _refreshDashboard();
  }

  Future<void> recordPurchase({
    String? id,
    required String supplierId,
    required String supplierName,
    required List<PurchaseLineItem> lines,
    required double paidAmount,
    required DateTime? dueAt,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('At least one purchase line is required');
    }
    final now = DateTime.now().toUtc();
    final purchaseId = id ?? newId('purchase');
    final totalAmount = lines.fold<double>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    final normalizedPaid = paidAmount.clamp(0, totalAmount);
    final remainingAmount = (totalAmount - normalizedPaid).clamp(
      0,
      double.infinity,
    );
    final paymentStatus = remainingAmount <= 0
        ? PurchasePaymentStatus.paid
        : normalizedPaid > 0
        ? PurchasePaymentStatus.partial
        : PurchasePaymentStatus.unpaid;
    final productMap = _productPayloadMap();
    for (final line in lines) {
      final payload = productMap[line.productId];
      final existing = payload == null ? null : ProductItem.fromMap(payload);
      final currentStock = existing?.stockQuantity ?? 0;
      final previousCost = payload == null
          ? 0.0
          : asDouble(payload['costPrice']);
      final nextStock = currentStock + line.quantity;
      final nextCost = nextStock <= 0
          ? line.unitPrice
          : (((previousCost * currentStock) +
                    (line.unitPrice * line.quantity)) /
                nextStock);
      final nextPayload = <String, dynamic>{
        'id': existing?.id ?? line.productId,
        'name': existing?.name ?? line.label,
        'sku': existing?.sku ?? '',
        'unitPrice': existing?.unitPrice ?? line.unitPrice,
        'costPrice': nextCost,
        'stockQuantity': nextStock,
        'createdAt':
            existing?.createdAt.toUtc().toIso8601String() ??
            now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      await _store.upsertRecord(
        'product',
        nextPayload['id'] as String,
        nextPayload,
      );
      await _store
          .upsertRecord('stock_movement', newId('stock'), <String, dynamic>{
            'id': newId('stock'),
            'productId': nextPayload['id'],
            'label': nextPayload['name'],
            'direction': 'in',
            'quantity': line.quantity,
            'unitPrice': line.unitPrice,
            'costPrice': line.unitPrice,
            'createdAt': now.toIso8601String(),
            'sourceId': purchaseId,
            'sourceType': 'purchase',
          });
    }
    final payload = <String, dynamic>{
      'id': purchaseId,
      'supplierId': supplierId,
      'supplierName': supplierName.trim(),
      'lines': lines.map((line) => line.toMap()).toList(growable: false),
      'totalAmount': totalAmount,
      'paidAmount': normalizedPaid,
      'remainingAmount': remainingAmount,
      'dueAt': dueAt?.toUtc().toIso8601String(),
      'paymentStatus': paymentStatus.code,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    await _store.upsertRecord('purchase', purchaseId, payload);
    if (normalizedPaid > 0) {
      await _store.upsertRecord(
        'purchase_payment',
        newId('purchase-payment'),
        <String, dynamic>{
          'id': newId('purchase-payment'),
          'purchaseId': purchaseId,
          'amount': normalizedPaid,
          'method': 'cash',
          'note': paymentStatus == PurchasePaymentStatus.paid
              ? 'Règlement immédiat'
              : 'Acompte initial',
          'createdAt': now.toIso8601String(),
        },
      );
    }
    await _loadPurchases();
    await _loadPurchasePayments();
    await _loadProducts();
    await _refreshDashboard();
  }

  Future<void> addPurchasePayment({
    required String purchaseId,
    required double amount,
    required String note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be positive');
    }
    final purchaseRecord = await _store.getRecord('purchase', purchaseId);
    if (purchaseRecord == null) {
      throw StateError('Purchase not found');
    }
    final purchase = PurchaseItem.fromMap(purchaseRecord.payload);
    final nextPaid = (purchase.paidAmount + amount).clamp(
      0,
      purchase.totalAmount,
    );
    final nextRemaining = (purchase.totalAmount - nextPaid).clamp(
      0,
      double.infinity,
    );
    final nextStatus = nextRemaining <= 0
        ? PurchasePaymentStatus.paid
        : nextPaid > 0
        ? PurchasePaymentStatus.partial
        : PurchasePaymentStatus.unpaid;
    final now = DateTime.now().toUtc();
    await _store.upsertRecord(
      'purchase_payment',
      newId('purchase-payment'),
      <String, dynamic>{
        'id': newId('purchase-payment'),
        'purchaseId': purchaseId,
        'amount': amount,
        'method': 'cash',
        'note': note.trim(),
        'createdAt': now.toIso8601String(),
      },
    );
    await _store.upsertRecord('purchase', purchaseId, <String, dynamic>{
      ...purchase.toMap(),
      'paidAmount': nextPaid,
      'remainingAmount': nextRemaining,
      'paymentStatus': nextStatus.code,
      'updatedAt': now.toIso8601String(),
    });
    await _loadPurchases();
    await _loadPurchasePayments();
    await _refreshDashboard();
  }

  Future<void> deleteRecord(String type, String id) async {
    await _store.markDeleted(type, id);
    if (type == 'product') {
      await _loadProducts();
    } else if (type == 'customer') {
      await _loadCustomers();
    } else if (type == 'supplier') {
      await _loadSuppliers();
    } else if (type == 'sale') {
      await _loadSales();
    } else if (type == 'purchase') {
      await _loadPurchases();
    } else if (type == 'expense') {
      await _loadExpenses();
    }
    await _refreshDashboard();
  }

  Future<void> syncNow() async {
    if (syncing.value) return;
    final api = _cloudApi;
    if (api == null || license.value == null || !license.value!.isValid) {
      return;
    }
    syncing.value = true;
    syncMessage.value = 'Synchronisation en cours';
    try {
      final pending = await _store.pendingChanges();
      final localRevision = await _store.getRevision();
      if (pending.isNotEmpty) {
        final push = await api.pushChanges(
          tenantKey: license.value!.tenantKey,
          deviceId: _deviceId,
          sinceRevision: _serverRevision == null
              ? 0
              : int.tryParse(_serverRevision!) ?? 0,
          changes: pending,
        );
        final ackIds = <int>[];
        final pushed = push['applied_change_ids'];
        if (pushed is List) {
          ackIds.addAll(
            pushed.map((e) => asInt(e)).where((value) => value > 0),
          );
        }
        if (ackIds.isEmpty) {
          ackIds.addAll(pending.map((change) => change.id));
        }
        await _store.markChangesSynced(ackIds);
        final serverRevision = push['server_revision'];
        if (serverRevision != null) {
          _serverRevision = serverRevision.toString();
          await _store.setValue('server_revision', _serverRevision!);
        }
      } else if (_serverRevision == null) {
        _serverRevision = localRevision.toString();
      }

      final pull = await api.pullChanges(
        tenantKey: license.value!.tenantKey,
        deviceId: _deviceId,
        sinceRevision: _serverRevision == null
            ? 0
            : int.tryParse(_serverRevision!) ?? 0,
      );
      final revision = pull['server_revision'];
      final records = pull['records'];
      var appliedRemoteChanges = false;
      if (records is List) {
        for (final item in records.whereType<Map>()) {
          final record = RecordEnvelope.fromMap(
            Map<String, dynamic>.from(item),
          );
          await _store.upsertRecord(
            record.type,
            record.entityId,
            record.payload,
            deleted: record.deleted,
            queueChange: false,
            revisionOverride: record.revision,
          );
          appliedRemoteChanges = true;
        }
      }
      if (revision != null) {
        _serverRevision = revision.toString();
        await _store.setValue('server_revision', _serverRevision!);
      }
      if (appliedRemoteChanges) {
        await _loadAll();
      }
      syncMessage.value = 'Synchronisation à jour';
    } catch (error) {
      syncMessage.value = 'Synchronisation indisponible';
    } finally {
      syncing.value = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }

  Future<void> _restoreLicense() async {
    final raw = await _store.getValue('license_state');
    if (raw == null || raw.isEmpty) {
      license.value = null;
      return;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      license.value = null;
      return;
    }
    license.value = LicenseState.fromMap(decoded);
  }

  Future<void> _restoreSession() async {
    final raw = await _store.getValue('session');
    if (raw == null || raw.isEmpty) {
      session.value = null;
      return;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      session.value = null;
      return;
    }
    final restored = AppSession.fromMap(decoded);
    final known = users.value
        .where((user) => user.id == restored.user.id)
        .toList(growable: false);
    session.value = known.isEmpty ? null : restored;
    if (session.value == null) {
      await _store.removeValue('session');
    }
  }

  Future<void> _switchToBusinessTenant(LicenseState state) async {
    await _store.init(state.tenantKey);
    _serverRevision = await _store.getValue('server_revision');
  }

  Future<void> _loadAll() async {
    await Future.wait(<Future<void>>[
      _loadUsers(),
      _loadProducts(),
      _loadCustomers(),
      _loadSuppliers(),
      _loadSales(),
      _loadPurchases(),
      _loadPurchasePayments(),
      _loadExpenses(),
    ]);
    await _refreshDashboard();
  }

  Future<void> _loadUsers() async {
    final records = await _store.listRecords(type: 'user');
    users.value = records
        .map((record) => AppUser.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final records = await _store.listRecords(type: 'product');
    products.value = records
        .map((record) => ProductItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadCustomers() async {
    final records = await _store.listRecords(type: 'customer');
    customers.value = records
        .map((record) => CustomerItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadSuppliers() async {
    final records = await _store.listRecords(type: 'supplier');
    suppliers.value = records
        .map((record) => SupplierItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadSales() async {
    final records = await _store.listRecords(type: 'sale');
    sales.value = records
        .map((record) => SaleItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadPurchases() async {
    final records = await _store.listRecords(type: 'purchase');
    purchases.value = records
        .map((record) => PurchaseItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadPurchasePayments() async {
    final records = await _store.listRecords(type: 'purchase_payment');
    purchasePayments.value = records
        .map((record) => PurchasePaymentItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _loadExpenses() async {
    final records = await _store.listRecords(type: 'expense');
    expenses.value = records
        .map((record) => ExpenseItem.fromMap(record.payload))
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _refreshDashboard() async {
    final recentSales = sales.value;
    final recentPurchases = purchases.value;
    final totalSales = recentSales.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );
    final totalPurchases = recentPurchases.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );
    final totalExpenses = expenses.value.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalProfit =
        recentSales.fold<double>(0, (sum, item) => sum + item.profitAmount) -
        totalExpenses;
    final stockValue = _stockValue();
    final creditBalance = recentPurchases.fold<double>(
      0,
      (sum, item) => sum + item.remainingAmount,
    );
    final lowStockCount = products.value
        .where((product) => product.stockQuantity <= 5)
        .length;
    dashboard.value = DashboardSnapshot(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalExpenses: totalExpenses,
      totalProfit: totalProfit,
      stockValue: stockValue,
      salesCount: recentSales.length,
      purchaseCount: recentPurchases.length,
      creditBalance: creditBalance,
      lowStockCount: lowStockCount,
      recentDailySales: _dailySeries(
        recentSales
            .map((sale) => (sale.createdAt, sale.totalAmount))
            .toList(growable: false),
      ),
      recentDailyPurchases: _dailySeries(
        recentPurchases
            .map((purchase) => (purchase.createdAt, purchase.totalAmount))
            .toList(growable: false),
      ),
    );
    notifyListeners();
  }

  List<double> _dailySeries(List<(DateTime, double)> entries) {
    final today = DateTime.now().toUtc();
    final buckets = List<double>.filled(7, 0);
    for (final entry in entries) {
      final diff = today
          .difference(DateTime.utc(entry.$1.year, entry.$1.month, entry.$1.day))
          .inDays;
      if (diff >= 0 && diff < 7) {
        buckets[6 - diff] += entry.$2;
      }
    }
    return buckets;
  }

  double _stockValue() {
    return products.value.fold<double>(0, (sum, product) {
      final raw = _productPayloadMap()[product.id];
      final cost = raw == null ? product.unitPrice : asDouble(raw['costPrice']);
      return sum + (product.stockQuantity * cost);
    });
  }

  Map<String, Map<String, dynamic>> _productPayloadMap() {
    final map = <String, Map<String, dynamic>>{};
    for (final record in products.value) {
      map[record.id] = record.toMap();
    }
    return map;
  }

  String _tenantKeyFromLicense(String licenseKey) {
    final normalized = licenseKey.trim().toLowerCase();
    var hash = 0x811c9dc5;
    for (final unit in normalized.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'tenant-${hash.toRadixString(16).padLeft(8, '0')}';
  }

  String _hashPassword(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<String> _ensureDeviceId() async {
    final existing = await _store.getValue('device_id');
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = newId('device');
    await _store.setValue('device_id', generated);
    return generated;
  }

  void _startSyncLoop() {
    _syncTimer ??= Timer.periodic(const Duration(seconds: 25), (_) {
      unawaited(syncNow());
    });
  }

  void _stopSyncLoop() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _validateLicenseInBackground() async {
    final state = license.value;
    final api = _cloudApi;
    if (state == null || api == null) return;
    try {
      final response = await api.validateLicense(
        licenseKey: state.licenseKey,
        deviceId: _deviceId,
      );
      final valid = response['valid'] == true;
      if (!valid) {
        await invalidateLicense();
        return;
      }
      final updated = state.copyWith(
        status: 'valid',
        lastValidatedAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      license.value = updated;
      await _store.setValue('license_state', encodeJson(updated.toMap()));
    } catch (_) {
      // Offline or backend unavailable: keep cached valid license.
    }
  }

  @override
  void dispose() {
    _stopSyncLoop();
    phase.dispose();
    license.dispose();
    session.dispose();
    syncing.dispose();
    syncMessage.dispose();
    dashboard.dispose();
    products.dispose();
    customers.dispose();
    suppliers.dispose();
    sales.dispose();
    purchases.dispose();
    purchasePayments.dispose();
    expenses.dispose();
    users.dispose();
    super.dispose();
  }
}
