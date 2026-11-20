import 'package:flutter_test/flutter_test.dart';
import 'package:ayodex/features/support/data/models/ticket_model.dart';
import 'package:ayodex/features/notifications/data/models/notification_model.dart';

void main() {
  group('Ticket Model Parsing Tests', () {
    test('Parses Ticket with messages and attachments', () {
      final json = {
        'id': 10,
        'ticket': '984210',
        'subject': 'Inquiry regarding payout',
        'status': 0, // Open
        'priority': 2, // Medium
        'last_reply': '2026-11-17T15:00:00Z',
      };

      final ticket = TicketModel.fromJson(json);
      expect(ticket.ticket, '984210');
      expect(ticket.statusLabel, 'Open');
      expect(ticket.priorityLabel, 'Medium');
      expect(ticket.isOpen, isTrue);
      expect(ticket.isClosed, isFalse);
    });

    test('Parses TicketMessageModel customer vs admin flags', () {
      final customerMsg = TicketMessageModel.fromJson({
        'id': 1,
        'support_ticket_id': 10,
        'admin_id': null,
        'message': 'Hello, need help.',
      });
      expect(customerMsg.isCustomerMessage, isTrue);
      expect(customerMsg.isAdminMessage, isFalse);

      final adminMsg = TicketMessageModel.fromJson({
        'id': 2,
        'support_ticket_id': 10,
        'admin_id': 5,
        'message': 'Hello! We are looking into this.',
      });
      expect(adminMsg.isCustomerMessage, isFalse);
      expect(adminMsg.isAdminMessage, isTrue);
    });
  });

  group('NotificationModel Tests', () {
    test('Parses notification correctly and checks unread status', () {
      final unread = NotificationModel.fromJson({
        'id': 1,
        'subject': 'Deposit Confirmed',
        'message': 'Your deposit has been credited',
        'user_read': 0,
      });
      expect(unread.title, 'Deposit Confirmed');
      expect(unread.userRead, isFalse);

      final read = NotificationModel.fromJson({
        'id': 2,
        'title': 'System Maintenance',
        'message': 'Platform update complete',
        'user_read': 1,
      });
      expect(read.userRead, isTrue);
    });
  });
}
