class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final bool userRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    this.userRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      title: json['subject']?.toString() ?? json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      userRead: json['user_read'] == 1 || json['user_read'] == '1' || json['user_read'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'message': message,
    'user_read': userRead ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
  };
}
