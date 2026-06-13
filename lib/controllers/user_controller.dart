import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/auth_controller.dart';
import '../models/category_model.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';
import '../models/service_request_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final firebaseService = FirebaseService.instance;
  final authController = AuthController.instance;

  final RxList<Category> categories = <Category>[].obs;
  final RxList<Provider> providers = <Provider>[].obs;
  final RxList<ServiceRequest> requests = <ServiceRequest>[].obs;
  final RxList<Review> reviews = <Review>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        firebaseService.getCategories(),
        firebaseService.getApprovedProviders(),
      ]);
      final list = results[0] as List<Category>;
      categories.assignAll(list.isEmpty ? AppConstants.defaultCategories : list);
      providers.assignAll(results[1] as List<Provider>);
    } catch (e) {
      categories.assignAll(AppConstants.defaultCategories);
      Get.snackbar('Error', 'Failed to load providers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    selectedCategoryId.value = categoryId ?? '';
    try {
      isLoading.value = true;
      if (categoryId == null || categoryId.isEmpty) {
        final list = await firebaseService.getApprovedProviders();
        providers.assignAll(list);
      } else {
        final list = await firebaseService.getApprovedProviders(
          categoryId: categoryId,
        );
        providers.assignAll(list);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter providers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProviders(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      await filterByCategory(
        selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
      );
      return;
    }

    try {
      isLoading.value = true;
      final results = await firebaseService.searchProviders(query.trim());
      providers.assignAll(results);
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  String categoryName(String categoryId) {
    return categories
            .firstWhereOrNull((c) => c.categoryId == categoryId)
            ?.categoryName ??
        'Unknown';
  }

  Future<void> loadProviderReviews(String providerId) async {
    try {
      final list = await firebaseService.getProviderReviews(providerId);
      reviews.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reviews');
    }
  }

  Future<void> loadUserRequests() async {
    final userId = authController.appUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final list = await firebaseService.getUserRequests(userId);
      requests.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitServiceRequest({
    required Provider provider,
    required String description,
    String? preferredDate,
    double? budget,
  }) async {
    final userId = authController.appUser.value?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not authenticated. Please login again.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final request = ServiceRequest(
        requestId: const Uuid().v4(),
        userId: userId,
        providerId: provider.providerId,
        categoryId: provider.categoryId,
        description: description,
        status: AppConstants.requestPending,
        createdAt: DateTime.now(),
        preferredDate: preferredDate,
        budget: budget,
      );

      await firebaseService.createServiceRequest(request);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> cancelRequest(ServiceRequest request) async {
    if (request.status != AppConstants.requestPending) {
      Get.snackbar('Info', 'This request can no longer be cancelled');
      return;
    }

    try {
      await firebaseService.updateServiceRequest(request.requestId, {
        'status': AppConstants.requestCancelled,
      });
      await loadUserRequests();
      Get.snackbar('Success', 'Request cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel request');
    }
  }

  Future<bool> submitReview({
    required String providerId,
    required String requestId,
    required double rating,
    required String comment,
  }) async {
    final userId = authController.appUser.value?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'User not authenticated. Please login again.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final review = Review(
        reviewId: const Uuid().v4(),
        userId: userId,
        providerId: providerId,
        requestId: requestId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await firebaseService.createReview(review);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit review: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
