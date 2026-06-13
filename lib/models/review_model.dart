import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  late String reviewId;

  late String userId; // Reference to User leaving the review
  late String providerId; // Reference to Provider being reviewed
  late String requestId; // Reference to ServiceRequest

  late double rating; // 1.0 to 5.0

  late String comment;

  late DateTime createdAt;

  Review({
    required this.reviewId,
    required this.userId,
    required this.providerId,
    required this.requestId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'providerId': providerId,
      'requestId': requestId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'] ?? '',
      requestId: json['requestId'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
