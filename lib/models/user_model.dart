enum UserRole { user, provider, admin }

class User {
  late String uid; // Firebase UID

  late String fullName;

  late String email;

  late String phoneNumber;

  late String role; // 'user', 'provider', 'admin'

  late DateTime createdAt;
  late DateTime updatedAt;

  String? profilePictureUrl;
  String? profilePicturePath; // Local path for offline

  bool isVerified = false;
  bool isActive = true;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.profilePictureUrl,
    this.profilePicturePath,
    this.isVerified = false,
    this.isActive = true,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profilePictureUrl': profilePictureUrl,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      profilePictureUrl: json['profilePictureUrl'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}
