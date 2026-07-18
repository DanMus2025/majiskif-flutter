import 'package:flutter_test/flutter_test.dart';
import 'package:majiskif/main.dart';

void main() {
  group('AppStore messaging', () {
    test('sent messages are not counted as unread for the sender', () {
      final store = AppStore.demo();
      final recipient =
          store.users.firstWhere((user) => user.code != store.activeUser.code);

      store.sendInternalMessage(
        recipient: recipient,
        body: 'Message de test',
      );

      expect(store.unreadMessages, 0);
    });

    test('incoming messages are counted unread then cleared when read', () {
      final store = AppStore.demo();
      final admin = store.users.firstWhere((user) => user.isAdmin);
      final manager = store.users.firstWhere((user) => user.isManager);
      store.activeUser = manager;
      final baselineUnread = store.unreadMessages;

      final incoming = AppMessage.chat(
        id: 'chat-incoming-manager',
        senderCode: admin.code,
        senderName: admin.name,
        recipientCode: manager.code,
        recipientName: manager.name,
        body: 'Bonjour gestionnaire',
        createdAt: DateTime.now(),
      );

      store.messages.add(incoming);

      expect(store.unreadMessages, baselineUnread + 1);

      store.markMessageRead(incoming);

      expect(store.unreadMessages, baselineUnread);
      expect(store.readMessageIds.contains(incoming.id), isTrue);
      final saved =
          store.messages.firstWhere((message) => message.id == incoming.id);
      expect(saved.recipientReadAt, isNotNull);
    });

    test('conversation marks only peer incoming messages as read', () {
      final store = AppStore.demo();
      final admin = store.users.firstWhere((user) => user.isAdmin);
      final manager = store.users.firstWhere((user) => user.isManager);
      final cashier = store.users.firstWhere((user) => user.isCashier);
      store.activeUser = manager;
      final baselineUnread = store.unreadMessages;

      final fromAdmin = AppMessage.chat(
        id: 'chat-from-admin',
        senderCode: admin.code,
        senderName: admin.name,
        recipientCode: manager.code,
        recipientName: manager.name,
        body: 'Message admin',
        createdAt: DateTime.now(),
      );
      final fromCashier = AppMessage.chat(
        id: 'chat-from-cashier',
        senderCode: cashier.code,
        senderName: cashier.name,
        recipientCode: manager.code,
        recipientName: manager.name,
        body: 'Message caissier',
        createdAt: DateTime.now(),
      );

      store.messages.addAll([fromAdmin, fromCashier]);

      expect(store.unreadMessages, baselineUnread + 2);

      store.markMessagesFromPeerAsRead(admin);

      expect(store.readMessageIds.contains(fromAdmin.id), isTrue);
      expect(store.readMessageIds.contains(fromCashier.id), isFalse);
      expect(store.unreadMessages, 1);
    });

    test('cashier credit sale notifies manager and admin automatically', () {
      final store = AppStore.demo();
      final cashier = store.users.firstWhere((user) => user.isCashier);
      final cart = [CartLine(product: store.products.first)];

      final sale = store.completeSale(
        cart: cart,
        customer: store.customers.first,
        method: 'Credit',
        paid: 0,
        discount: 0,
        cashier: cashier,
      );

      expect(sale.due, greaterThan(0));

      final creditNotifications = store.messages
          .where((message) => message.title == 'Vente a credit enregistree')
          .toList();

      expect(creditNotifications.length, 2);
      expect(
        creditNotifications.every(
          (message) =>
              message.recipientCode != null &&
              message.recipientCode != cashier.code,
        ),
        isTrue,
      );
      expect(
        creditNotifications.any(
          (message) =>
              message.recipientCode ==
              store.users.firstWhere((user) => user.isAdmin).code,
        ),
        isTrue,
      );
      expect(
        creditNotifications.any(
          (message) =>
              message.recipientCode ==
              store.users.firstWhere((user) => user.isManager).code,
        ),
        isTrue,
      );
    });

    test('settling a debt notifies the admin automatically', () {
      final store = AppStore.demo();
      final cashier = store.users.firstWhere((user) => user.isCashier);
      final admin = store.users.firstWhere((user) => user.isAdmin);
      final cart = [CartLine(product: store.products.first)];

      final sale = store.completeSale(
        cart: cart,
        customer: store.customers.first,
        method: 'Credit',
        paid: 0,
        discount: 0,
        cashier: cashier,
      );

      final settled = store.settleSaleCredit(sale, actor: cashier);

      expect(settled, greaterThan(0));

      final settlementNotifications = store.messages
          .where(
            (message) =>
                message.title == 'Dette payee' &&
                message.recipientCode == admin.code,
          )
          .toList();

      expect(settlementNotifications, isNotEmpty);
      expect(
        settlementNotifications.last.body.contains(sale.invoiceNo),
        isTrue,
      );
    });
  });
}
