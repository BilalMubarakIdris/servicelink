import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  late String notificationId;
  late String userId;
  late String title;
  late String message;
  late String type; // 'request_accepted', 'request_rejected', 'request_completed', 'request_started'
  late String? requestId;
  late bool isRead;
  late DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.requestId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'requestId': requestId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      requestId: json['requestId'],
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
