import 'dart:convert';
import 'dart:math';

String newId([String prefix = 'id']) {
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = Random().nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
  return '$prefix-$now-$rand';
}

String isoNow() => DateTime.now().toUtc().toIso8601String();

DateTime parseUtc(String value) => DateTime.parse(value).toUtc();

double asDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int asInt(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String asText(Object? value, [String fallback = '']) {
  final result = value?.toString().trim();
  return (result == null || result.isEmpty) ? fallback : result;
}

Map<String, dynamic> asJsonMap(Object? value) {
  if (value == null) return <String, dynamic>{};
  if (value is Map<String, dynamic>) return value;
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) return decoded;
  }
  return <String, dynamic>{};
}

String encodeJson(Map<String, dynamic> value) => jsonEncode(value);

enum PurchasePaymentStatus { unpaid, partial, paid }

extension PurchasePaymentStatusX on PurchasePaymentStatus {
  String get label => switch (this) {
    PurchasePaymentStatus.unpaid => 'Non payé',
    PurchasePaymentStatus.partial => 'Partiellement payé',
    PurchasePaymentStatus.paid => 'Totalement payé',
  };

  String get code => switch (this) {
    PurchasePaymentStatus.unpaid => 'unpaid',
    PurchasePaymentStatus.partial => 'partial',
    PurchasePaymentStatus.paid => 'paid',
  };

  static PurchasePaymentStatus fromCode(String value) {
    return switch (value) {
      'partial' => PurchasePaymentStatus.partial,
      'paid' => PurchasePaymentStatus.paid,
      _ => PurchasePaymentStatus.unpaid,
    };
  }
}

class RecordEnvelope {
  const RecordEnvelope({
    required this.id,
    required this.type,
    required this.entityId,
    required this.tenantKey,
    required this.payload,
    required this.updatedAt,
    required this.revision,
    required this.deleted,
  });

  final String id;
  final String type;
  final String entityId;
  final String tenantKey;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;
  final int revision;
  final bool deleted;

  RecordEnvelope copyWith({
    Map<String, dynamic>? payload,
    DateTime? updatedAt,
    int? revision,
    bool? deleted,
  }) {
    return RecordEnvelope(
      id: id,
      type: type,
      entityId: entityId,
      tenantKey: tenantKey,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'type': type,
    'entityId': entityId,
    'tenantKey': tenantKey,
    'payload': payload,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'revision': revision,
    'deleted': deleted,
  };

  factory RecordEnvelope.fromMap(Map<String, dynamic> map) {
    return RecordEnvelope(
      id: asText(map['id'], newId('record')),
      type: asText(map['type']),
      entityId: asText(map['entityId']),
      tenantKey: asText(map['tenantKey']),
      payload: asJsonMap(map['payload']),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
      revision: asInt(map['revision']),
      deleted: map['deleted'] == true,
    );
  }
}

class ChangeEnvelope {
  const ChangeEnvelope({
    required this.id,
    required this.operation,
    required this.record,
    required this.createdAt,
    required this.synced,
  });

  final int id;
  final String operation;
  final RecordEnvelope record;
  final DateTime createdAt;
  final bool synced;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'operation': operation,
    'record': record.toMap(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'synced': synced,
  };

  factory ChangeEnvelope.fromMap(Map<String, dynamic> map) {
    return ChangeEnvelope(
      id: asInt(map['id']),
      operation: asText(map['operation']),
      record: RecordEnvelope.fromMap(asJsonMap(map['record'])),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      synced: map['synced'] == true,
    );
  }
}

class LicenseState {
  const LicenseState({
    required this.licenseKey,
    required this.tenantKey,
    required this.ownerName,
    required this.deviceId,
    required this.activatedAt,
    required this.updatedAt,
    required this.status,
    this.expiresAt,
    this.lastValidatedAt,
    this.signature = '',
  });

  final String licenseKey;
  final String tenantKey;
  final String ownerName;
  final String deviceId;
  final DateTime activatedAt;
  final DateTime updatedAt;
  final String status;
  final DateTime? expiresAt;
  final DateTime? lastValidatedAt;
  final String signature;

  bool get isValid => status.toLowerCase() == 'valid';
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc());

  LicenseState copyWith({
    String? status,
    DateTime? updatedAt,
    DateTime? lastValidatedAt,
    DateTime? expiresAt,
    String? signature,
  }) {
    return LicenseState(
      licenseKey: licenseKey,
      tenantKey: tenantKey,
      ownerName: ownerName,
      deviceId: deviceId,
      activatedAt: activatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      signature: signature ?? this.signature,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'licenseKey': licenseKey,
    'tenantKey': tenantKey,
    'ownerName': ownerName,
    'deviceId': deviceId,
    'activatedAt': activatedAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'status': status,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'lastValidatedAt': lastValidatedAt?.toUtc().toIso8601String(),
    'signature': signature,
  };

  factory LicenseState.fromMap(Map<String, dynamic> map) {
    return LicenseState(
      licenseKey: asText(map['licenseKey']),
      tenantKey: asText(map['tenantKey']),
      ownerName: asText(map['ownerName']),
      deviceId: asText(map['deviceId']),
      activatedAt: parseUtc(asText(map['activatedAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
      status: asText(map['status'], 'invalid'),
      expiresAt: map['expiresAt'] == null || asText(map['expiresAt']).isEmpty
          ? null
          : parseUtc(asText(map['expiresAt'])),
      lastValidatedAt:
          map['lastValidatedAt'] == null ||
              asText(map['lastValidatedAt']).isEmpty
          ? null
          : parseUtc(asText(map['lastValidatedAt'])),
      signature: asText(map['signature']),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'passwordHash': passwordHash,
    'role': role,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: asText(map['id'], newId('user')),
      name: asText(map['name']),
      email: asText(map['email']),
      passwordHash: asText(map['passwordHash']),
      role: asText(map['role'], 'admin'),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.unitPrice,
    required this.stockQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final double unitPrice;
  final double stockQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'sku': sku,
    'unitPrice': unitPrice,
    'stockQuantity': stockQuantity,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      id: asText(map['id'], newId('product')),
      name: asText(map['name']),
      sku: asText(map['sku']),
      unitPrice: asDouble(map['unitPrice']),
      stockQuantity: asDouble(map['stockQuantity']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class CustomerItem {
  const CustomerItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'phone': phone,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory CustomerItem.fromMap(Map<String, dynamic> map) {
    return CustomerItem(
      id: asText(map['id'], newId('customer')),
      name: asText(map['name']),
      phone: asText(map['phone']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class SupplierItem {
  const SupplierItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'phone': phone,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory SupplierItem.fromMap(Map<String, dynamic> map) {
    return SupplierItem(
      id: asText(map['id'], newId('supplier')),
      name: asText(map['name']),
      phone: asText(map['phone']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class SaleLineItem {
  const SaleLineItem({
    required this.productId,
    required this.label,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String label;
  final double quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'productId': productId,
    'label': label,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'lineTotal': lineTotal,
  };

  factory SaleLineItem.fromMap(Map<String, dynamic> map) {
    return SaleLineItem(
      productId: asText(map['productId']),
      label: asText(map['label']),
      quantity: asDouble(map['quantity']),
      unitPrice: asDouble(map['unitPrice']),
    );
  }
}

class SaleItem {
  const SaleItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.lines,
    required this.totalAmount,
    required this.costAmount,
    required this.profitAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final List<SaleLineItem> lines;
  final double totalAmount;
  final double costAmount;
  final double profitAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'customerId': customerId,
    'customerName': customerName,
    'lines': lines.map((line) => line.toMap()).toList(growable: false),
    'totalAmount': totalAmount,
    'costAmount': costAmount,
    'profitAmount': profitAmount,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    final lines = (map['lines'] is List)
        ? (map['lines'] as List)
              .whereType<Map>()
              .map(
                (line) => SaleLineItem.fromMap(
                  Map<String, dynamic>.from(line as Map),
                ),
              )
              .toList(growable: false)
        : <SaleLineItem>[];
    return SaleItem(
      id: asText(map['id'], newId('sale')),
      customerId: asText(map['customerId']),
      customerName: asText(map['customerName']),
      lines: lines,
      totalAmount: asDouble(map['totalAmount']),
      costAmount: asDouble(map['costAmount']),
      profitAmount: asDouble(map['profitAmount']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class PurchaseLineItem {
  const PurchaseLineItem({
    required this.productId,
    required this.label,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String label;
  final double quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'productId': productId,
    'label': label,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'lineTotal': lineTotal,
  };

  factory PurchaseLineItem.fromMap(Map<String, dynamic> map) {
    return PurchaseLineItem(
      productId: asText(map['productId']),
      label: asText(map['label']),
      quantity: asDouble(map['quantity']),
      unitPrice: asDouble(map['unitPrice']),
    );
  }
}

class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.lines,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueAt,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseLineItem> lines;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? dueAt;
  final PurchasePaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'supplierId': supplierId,
    'supplierName': supplierName,
    'lines': lines.map((line) => line.toMap()).toList(growable: false),
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'remainingAmount': remainingAmount,
    'dueAt': dueAt?.toUtc().toIso8601String(),
    'paymentStatus': paymentStatus.code,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    final lines = (map['lines'] is List)
        ? (map['lines'] as List)
              .whereType<Map>()
              .map(
                (line) => PurchaseLineItem.fromMap(
                  Map<String, dynamic>.from(line as Map),
                ),
              )
              .toList(growable: false)
        : <PurchaseLineItem>[];
    return PurchaseItem(
      id: asText(map['id'], newId('purchase')),
      supplierId: asText(map['supplierId']),
      supplierName: asText(map['supplierName']),
      lines: lines,
      totalAmount: asDouble(map['totalAmount']),
      paidAmount: asDouble(map['paidAmount']),
      remainingAmount: asDouble(map['remainingAmount']),
      dueAt: map['dueAt'] == null || asText(map['dueAt']).isEmpty
          ? null
          : parseUtc(asText(map['dueAt'])),
      paymentStatus: PurchasePaymentStatusX.fromCode(
        asText(map['paymentStatus'], 'unpaid'),
      ),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
      updatedAt: parseUtc(asText(map['updatedAt'], isoNow())),
    );
  }
}

class PurchasePaymentItem {
  const PurchasePaymentItem({
    required this.id,
    required this.purchaseId,
    required this.amount,
    required this.method,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String purchaseId;
  final double amount;
  final String method;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'purchaseId': purchaseId,
    'amount': amount,
    'method': method,
    'note': note,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory PurchasePaymentItem.fromMap(Map<String, dynamic> map) {
    return PurchasePaymentItem(
      id: asText(map['id'], newId('purchase-payment')),
      purchaseId: asText(map['purchaseId']),
      amount: asDouble(map['amount']),
      method: asText(map['method'], 'cash'),
      note: asText(map['note']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
    );
  }
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String label;
  final double amount;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'label': label,
    'amount': amount,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: asText(map['id'], newId('expense')),
      label: asText(map['label']),
      amount: asDouble(map['amount']),
      createdAt: parseUtc(asText(map['createdAt'], isoNow())),
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.totalProfit,
    required this.stockValue,
    required this.salesCount,
    required this.purchaseCount,
    required this.creditBalance,
    required this.lowStockCount,
    required this.recentDailySales,
    required this.recentDailyPurchases,
  });

  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final double totalProfit;
  final double stockValue;
  final int salesCount;
  final int purchaseCount;
  final double creditBalance;
  final int lowStockCount;
  final List<double> recentDailySales;
  final List<double> recentDailyPurchases;

  factory DashboardSnapshot.empty() => const DashboardSnapshot(
    totalSales: 0,
    totalPurchases: 0,
    totalExpenses: 0,
    totalProfit: 0,
    stockValue: 0,
    salesCount: 0,
    purchaseCount: 0,
    creditBalance: 0,
    lowStockCount: 0,
    recentDailySales: <double>[],
    recentDailyPurchases: <double>[],
  );
}

class AppSession {
  const AppSession({required this.user, required this.startedAt});

  final AppUser user;
  final DateTime startedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'user': user.toMap(),
    'startedAt': startedAt.toUtc().toIso8601String(),
  };

  factory AppSession.fromMap(Map<String, dynamic> map) {
    return AppSession(
      user: AppUser.fromMap(asJsonMap(map['user'])),
      startedAt: parseUtc(asText(map['startedAt'], isoNow())),
    );
  }
}
