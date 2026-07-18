import '../main.dart';

class KeseStoreSnapshot {
  const KeseStoreSnapshot({
    required this.tenantId,
    required this.branchId,
    required this.deviceId,
    required this.exportedAt,
    required this.activeUserCode,
    required this.settings,
    required this.categories,
    required this.products,
    required this.customers,
    required this.suppliers,
    required this.users,
    required this.sales,
    required this.purchases,
    required this.expenses,
    required this.stockMoves,
    required this.alerts,
    required this.messages,
    required this.pendingSyncChanges,
    required this.lastSyncAt,
  });

  final String tenantId;
  final String branchId;
  final String deviceId;
  final DateTime exportedAt;
  final String activeUserCode;
  final Map<String, dynamic> settings;
  final List<String> categories;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> suppliers;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> sales;
  final List<Map<String, dynamic>> purchases;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> stockMoves;
  final List<Map<String, dynamic>> alerts;
  final List<Map<String, dynamic>> messages;
  final int pendingSyncChanges;
  final DateTime? lastSyncAt;

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'branchId': branchId,
        'deviceId': deviceId,
        'exportedAt': exportedAt.toIso8601String(),
        'activeUserCode': activeUserCode,
        'settings': settings,
        'categories': categories,
        'products': products,
        'customers': customers,
        'suppliers': suppliers,
        'users': users,
        'sales': sales,
        'purchases': purchases,
        'expenses': expenses,
        'stockMoves': stockMoves,
        'alerts': alerts,
        'messages': messages,
        'pendingSyncChanges': pendingSyncChanges,
        'lastSyncAt': lastSyncAt?.toIso8601String(),
      };
}

extension KeseStoreSnapshotExport on AppStore {
  KeseStoreSnapshot toSyncSnapshot() {
    return KeseStoreSnapshot(
      tenantId: tenantId,
      branchId: branchId,
      deviceId: deviceId,
      exportedAt: DateTime.now(),
      activeUserCode: activeUser.code,
      settings: {
        'companyName': settings.companyName,
        'ownerName': settings.ownerName,
        'logoUrl': settings.logoUrl,
        'pointOfSale': settings.pointOfSale,
        'phone': settings.phone,
        'email': settings.email,
        'address': settings.address,
        'rccm': settings.rccm,
        'idNat': settings.idNat,
        'nif': settings.nif,
        'efo': settings.efo,
        'currency': settings.currency,
        'taxRate': settings.taxRate,
      },
      categories: List<String>.from(categories),
      products: products
          .map(
            (product) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'code': product.code,
              'sku': product.sku,
              'barcode': product.barcode,
              'name': product.name,
              'category': product.category,
              'unit': product.unit,
              'cost': product.cost,
              'price': product.price,
              'quantity': product.quantity,
              'minQuantity': product.minQuantity,
              'location': product.location,
              'imageUrl': product.imageUrl,
            },
          )
          .toList(),
      customers: customers
          .map(
            (customer) => {
              'tenantId': tenantId,
              'code': customer.code,
              'name': customer.name,
              'phone': customer.phone,
              'address': customer.address,
            },
          )
          .toList(),
      suppliers: suppliers
          .map(
            (supplier) => {
              'tenantId': tenantId,
              'code': supplier.code,
              'name': supplier.name,
              'phone': supplier.phone,
              'address': supplier.address,
            },
          )
          .toList(),
      users: users
          .map(
            (user) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'code': user.code,
              'name': user.name,
              'username': user.username,
              'usernameNormalized': user.username.trim().toLowerCase(),
              'role': user.role,
              'pin': user.pin,
              'isBlocked': user.isBlocked,
            },
          )
          .toList(),
      sales: sales
          .map(
            (sale) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'orderNo': sale.orderNo,
              'invoiceNo': sale.invoiceNo,
              'ticketNo': sale.ticketNo,
              'customerCode': sale.customer.code,
              'customerName': sale.customer.name,
              'cashierCode': sale.cashierCode,
              'cashierName': sale.cashierName,
              'subtotal': sale.subtotal,
              'discount': sale.discount,
              'total': sale.total,
              'paid': sale.paid,
              'due': sale.due,
              'method': sale.method,
              'status': sale.status,
              'createdAt': sale.createdAt.toIso8601String(),
              'dueDate': sale.dueDate.toIso8601String(),
              'lines': sale.lines
                  .map(
                    (line) => {
                      'product': line.product,
                      'qty': line.qty,
                      'price': line.price,
                      'cost': line.cost,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      purchases: purchases
          .map(
            (purchase) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'reference': purchase.reference,
              'product': purchase.product,
              'supplier': purchase.supplier,
              'quantity': purchase.quantity,
              'total': purchase.total,
              'paid': purchase.paid,
              'due': purchase.due,
              'createdAt': purchase.createdAt.toIso8601String(),
            },
          )
          .toList(),
      expenses: expenses
          .map(
            (expense) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'label': expense.label,
              'amount': expense.amount,
              'createdAt': expense.createdAt.toIso8601String(),
            },
          )
          .toList(),
      stockMoves: stockMoves
          .map(
            (move) => {
              'tenantId': tenantId,
              'branchId': branchId,
              'type': move.type,
              'product': move.product,
              'quantity': move.quantity,
              'reference': move.reference,
              'createdAt': move.createdAt.toIso8601String(),
            },
          )
          .toList(),
      alerts: alerts
          .map(
            (alert) => {
              'tenantId': tenantId,
              'id': alert.id,
              'title': alert.title,
              'body': alert.body,
              'level': alert.level.name,
              'createdAt': alert.createdAt.toIso8601String(),
              'readAt': alert.readAt?.toIso8601String(),
            },
          )
          .toList(),
      messages: messages
          .map(
            (message) => {
              'tenantId': tenantId,
              'id': message.id,
              'title': message.title,
              'body': message.body,
              'type': message.type,
              'createdAt': message.createdAt.toIso8601String(),
              'senderCode': message.senderCode,
              'senderName': message.senderName,
              'recipientCode': message.recipientCode,
              'recipientName': message.recipientName,
              'readAt': message.readAt?.toIso8601String(),
            },
          )
          .toList(),
      pendingSyncChanges: pendingSyncChanges,
      lastSyncAt: lastSyncAt,
    );
  }
}
