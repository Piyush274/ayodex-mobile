class TicketAttachmentModel {
  final int id;
  final String attachment;

  const TicketAttachmentModel({
    required this.id,
    required this.attachment,
  });

  factory TicketAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TicketAttachmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      attachment: json['attachment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attachment': attachment,
  };
}

class TicketMessageModel {
  final int id;
  final int supportTicketId;
  final int? adminId;
  final String message;
  final List<TicketAttachmentModel> attachments;
  final DateTime? createdAt;

  const TicketMessageModel({
    required this.id,
    required this.supportTicketId,
    this.adminId,
    required this.message,
    this.attachments = const [],
    this.createdAt,
  });

  bool get isCustomerMessage => adminId == null || adminId == 0;
  bool get isAdminMessage => !isCustomerMessage;

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'] as List<dynamic>? ?? [];
    final parsedAttachments = rawAttachments
        .whereType<Map<String, dynamic>>()
        .map((e) => TicketAttachmentModel.fromJson(e))
        .toList();

    return TicketMessageModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      supportTicketId: int.tryParse(json['support_ticket_id']?.toString() ?? '0') ?? 0,
      adminId: json['admin_id'] != null ? int.tryParse(json['admin_id'].toString()) : null,
      message: json['message']?.toString() ?? '',
      attachments: parsedAttachments,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'support_ticket_id': supportTicketId,
    'admin_id': adminId,
    'message': message,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
}

class TicketModel {
  final int id;
  final String ticket;
  final String subject;
  final int status; // 0=open, 1=answer, 2=reply, 3=close
  final int priority; // 1=low, 2=medium, 3=high
  final DateTime? lastReply;
  final DateTime? createdAt;
  final List<TicketMessageModel> messages;

  const TicketModel({
    required this.id,
    required this.ticket,
    required this.subject,
    this.status = 0,
    this.priority = 2,
    this.lastReply,
    this.createdAt,
    this.messages = const [],
  });

  bool get isOpen => status == 0;
  bool get isAnswered => status == 1;
  bool get isReplied => status == 2;
  bool get isClosed => status == 3;

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Open';
      case 1:
        return 'Answered';
      case 2:
        return 'Customer Reply';
      case 3:
        return 'Closed';
      default:
        return 'Open';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Normal';
    }
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final parsedMessages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map((e) => TicketMessageModel.fromJson(e))
        .toList();

    return TicketModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticket: json['ticket']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      priority: json['priority'] is int ? json['priority'] as int : int.tryParse(json['priority']?.toString() ?? '2') ?? 2,
      lastReply: json['last_reply'] != null ? DateTime.tryParse(json['last_reply'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket': ticket,
    'subject': subject,
    'status': status,
    'priority': priority,
    'last_reply': lastReply?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'messages': messages.map((e) => e.toJson()).toList(),
  };
}
