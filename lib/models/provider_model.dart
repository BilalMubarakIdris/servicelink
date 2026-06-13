enum ApprovalStatus { pending, approved, rejected, suspended }

class Provider {
  late String providerId;

  late String userId; // Reference to User
  late String categoryId; // Reference to Category

  late String fullName;
  late String email;
  late String phoneNumber;

  late int yearsOfExperience;
  late String serviceDescription;

  late String state;
  late String localGovernmentArea;
  late String address;

  late double latitude;
  late double longitude;

  String? profilePictureUrl;
  String? profilePicturePath;

  late String approvalStatus; // 'pending', 'approved', 'rejected', 'suspended'

  double averageRating = 0.0;
  int totalReviews = 0;

  late DateTime createdAt;
  late DateTime updatedAt;

  Provider({
    required this.providerId,
    required this.userId,
    required this.categoryId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.yearsOfExperience,
    required this.serviceDescription,
    required this.state,
    required this.localGovernmentArea,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.profilePictureUrl,
    this.profilePicturePath,
    this.approvalStatus = 'pending',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'userId': userId,
      'categoryId': categoryId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'yearsOfExperience': yearsOfExperience,
      'serviceDescription': serviceDescription,
      'state': state,
      'localGovernmentArea': localGovernmentArea,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profilePictureUrl': profilePictureUrl,
      'approvalStatus': approvalStatus,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from JSON
  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      providerId: json['providerId'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      serviceDescription: json['serviceDescription'] ?? '',
      state: json['state'] ?? '',
      localGovernmentArea: json['localGovernmentArea'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      profilePictureUrl: json['profilePictureUrl'],
      approvalStatus: json['approvalStatus'] ?? 'pending',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
