import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../models/service_request_model.dart';
import '../models/review_model.dart';
import '../models/category_model.dart';
import '../models/app_notification_model.dart';
import '../utils/constants.dart';

class FirebaseService extends GetxService {
  static FirebaseService get instance => Get.find();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  Future<firebase_auth.UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }
  }

  Future<firebase_auth.UserCredential> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // User Firestore Methods
  Future<void> createUser(User user) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Provider Methods
  Future<void> createProvider(Provider provider) async {
    try {
      await _db
          .collection(AppConstants.providersCollection)
          .doc(provider.providerId)
          .set(provider.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<Provider?> getProvider(String providerId) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(AppConstants.providersCollection)
          .doc(providerId)
          .get();

      if (doc.exists) {
        return Provider.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Provider?> getProviderByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.providersCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Provider.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Provider>> getApprovedProviders({
    String? categoryId,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      Query query = _db
          .collection(AppConstants.providersCollection)
          .where('approvalStatus', isEqualTo: AppConstants.statusApproved);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      query = query.limit(limit);
      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Provider.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Provider>> searchProviders(String query) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.providersCollection)
          .where('approvalStatus', isEqualTo: AppConstants.statusApproved)
          .limit(20)
          .get();

      List<Provider> providers = snapshot.docs
          .map((doc) => Provider.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter locally for name search
      return providers
          .where(
            (provider) =>
                provider.fullName.toLowerCase().contains(query.toLowerCase()) ||
                provider.serviceDescription.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Provider>> getPendingProviders({
    int limit = AppConstants.pageSize,
  }) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.providersCollection)
          .where('approvalStatus', isEqualTo: AppConstants.statusPending)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Provider.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProviderApprovalStatus(
    String providerId,
    String status,
  ) async {
    try {
      await _db
          .collection(AppConstants.providersCollection)
          .doc(providerId)
          .update({
            'approvalStatus': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // Category Methods
  Future<List<Category>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.categoriesCollection)
          .get();

      return snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Service Request Methods
  Future<void> createServiceRequest(ServiceRequest request) async {
    try {
      await _db
          .collection(AppConstants.serviceRequestsCollection)
          .doc(request.requestId)
          .set(request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ServiceRequest>> getUserRequests(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.serviceRequestsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map(
            (doc) =>
                ServiceRequest.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ServiceRequest>> getProviderRequests(String providerId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.serviceRequestsCollection)
          .where('providerId', isEqualTo: providerId)
          .get();

      final list = snapshot.docs
          .map(
            (doc) =>
                ServiceRequest.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateServiceRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db
          .collection(AppConstants.serviceRequestsCollection)
          .doc(requestId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Review Methods
  Future<void> createReview(Review review) async {
    try {
      await _db
          .collection(AppConstants.reviewsCollection)
          .doc(review.reviewId)
          .set(review.toJson());

      // Update provider's average rating
      await _updateProviderRating(review.providerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Review>> getProviderReviews(String providerId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.reviewsCollection)
          .where('providerId', isEqualTo: providerId)
          .get();

      final list = snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateProviderRating(String providerId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.reviewsCollection)
          .where('providerId', isEqualTo: providerId)
          .get();

      List<Review> reviews = snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      if (reviews.isEmpty) return;

      double averageRating =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

      await _db
          .collection(AppConstants.providersCollection)
          .doc(providerId)
          .update({
            'averageRating': averageRating,
            'totalReviews': reviews.length,
          });
    } catch (e) {
      rethrow;
    }
  }

  // Storage Methods
  Future<String> uploadProfilePicture(String filePath, String uid) async {
    try {
      Reference ref = _storage.ref().child(
        '${AppConstants.storageProfilePictures}$uid',
      );
      TaskSnapshot snapshot = await ref.putFile(File(filePath));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // System Statistics Methods
  Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      final results = await Future.wait([
        _db.collection(AppConstants.usersCollection).get(),
        _db
            .collection(AppConstants.providersCollection)
            .where('approvalStatus', isEqualTo: AppConstants.statusApproved)
            .get(),
        _db.collection(AppConstants.serviceRequestsCollection).get(),
        _db
            .collection(AppConstants.providersCollection)
            .where('approvalStatus', isEqualTo: AppConstants.statusPending)
            .get(),
      ]);

      return {
        'totalUsers': (results[0] as QuerySnapshot).size,
        'approvedProviders': (results[1] as QuerySnapshot).size,
        'totalRequests': (results[2] as QuerySnapshot).size,
        'pendingProviders': (results[3] as QuerySnapshot).size,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Admin Methods - Get All Users
  Future<List<User>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Admin Methods - Get All Providers
  Future<List<Provider>> getAllProviders() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.providersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Provider.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Admin Methods - Get All Service Requests
  Future<List<ServiceRequest>> getAllServiceRequests() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.serviceRequestsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              ServiceRequest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Category CRUD Methods
  Future<void> createCategory(Category category) async {
    try {
      await _db
          .collection(AppConstants.categoriesCollection)
          .doc(category.categoryId)
          .set(category.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _db
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Provider Update Methods
  Future<void> updateProvider(String providerId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(AppConstants.providersCollection)
          .doc(providerId)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // Automatic seeding method
  Future<void> seedCategoriesIfEmpty() async {
    try {
      final snapshot = await _db.collection(AppConstants.categoriesCollection).limit(1).get();
      if (snapshot.docs.isEmpty) {
        final defaultCategories = [
          Category(categoryId: 'electrician', categoryName: 'Electrician', description: 'Electrical installation & repairs'),
          Category(categoryId: 'plumber', categoryName: 'Plumber', description: 'Plumbing installations & repairs'),
          Category(categoryId: 'carpenter', categoryName: 'Carpenter', description: 'Woodworking & furniture building'),
          Category(categoryId: 'painter', categoryName: 'Painter', description: 'Wall painting & decoration'),
          Category(categoryId: 'cleaner', categoryName: 'Cleaner', description: 'House & office cleaning services'),
        ];
        for (var category in defaultCategories) {
          await createCategory(category);
        }
        print('Categories seeded successfully!');
      }
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }

  // Notification Methods
  Future<void> createNotification(AppNotification notification) async {
    try {
      await _db
          .collection(AppConstants.notificationsCollection)
          .doc(notification.notificationId)
          .set(notification.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
