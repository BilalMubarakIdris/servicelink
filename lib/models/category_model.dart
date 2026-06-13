class Category {
  late String categoryId;

  late String categoryName;

  String? description;
  String? iconUrl;

  DateTime createdAt = DateTime.now();

  Category({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.iconUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'iconUrl': iconUrl,
      'createdAt': createdAt,
    };
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
      createdAt: (json['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
