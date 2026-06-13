import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequest {
  late String requestId;

  late String userId; // Reference to User making the request
  late String providerId; // Reference to Provider
  late String categoryId; // Reference to Category

  late String description;
  late String
  status; // 'pending', 'accepted', 'rejected', 'inProgress', 'completed', 'cancelled'

  String? providerNotes;

  late DateTime createdAt;
  DateTime? acceptedAt;
  DateTime? completedAt;

  double? budget;
  String? preferredDate;

  ServiceRequest({
    required this.requestId,
    required this.userId,
    required this.providerId,
    required this.categoryId,
    required this.description,
    this.status = 'pending',
    this.providerNotes,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.budget,
    this.preferredDate,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'providerId': providerId,
      'categoryId': categoryId,
      'description': description,
      'status': status,
      'providerNotes': providerNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'budget': budget,
      'preferredDate': preferredDate,
    };
  }

  // Create from JSON
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      requestId: json['requestId'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      providerNotes: json['providerNotes'],
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      acceptedAt: (json['acceptedAt'] as dynamic)?.toDate(),
      completedAt: (json['completedAt'] as dynamic)?.toDate(),
      budget: (json['budget'] as num?)?.toDouble(),
      preferredDate: json['preferredDate'],
    );
  }
}
