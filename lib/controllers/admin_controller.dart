import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/provider_model.dart';
import '../models/service_request_model.dart';
import '../models/user_model.dart';
import '../models/app_notification_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class AdminController extends GetxController {
  static AdminController get instance => Get.find();

  final firebaseService = FirebaseService.instance;

  final RxList<User> users = <User>[].obs;
  final RxList<Provider> providers = <Provider>[].obs;
  final RxList<Provider> pendingProviders = <Provider>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<ServiceRequest> serviceRequests = <ServiceRequest>[].obs;

  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([loadStatistics(), loadPendingProviders()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStatistics() async {
    try {
      final stats = await firebaseService.getSystemStatistics();
      statistics.assignAll(stats);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statistics: $e');
    }
  }

  Future<void> loadPendingProviders() async {
    try {
      final list = await firebaseService.getPendingProviders();
      pendingProviders.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load pending providers: $e');
    }
  }

  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;
      final list = await firebaseService.getAllUsers();
      users.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllProviders() async {
    try {
      isLoading.value = true;
      final list = await firebaseService.getAllProviders();
      providers.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load providers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final list = await firebaseService.getCategories();
      categories.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllServiceRequests() async {
    try {
      isLoading.value = true;
      final list = await firebaseService.getAllServiceRequests();
      serviceRequests.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load service requests');
    } finally {
      isLoading.value = false;
    }
  }

  // Provider Approval Actions
  Future<void> approveProvider(String providerId) async {
    try {
      isSubmitting.value = true;

      final provider = await firebaseService.getProvider(providerId);

      await firebaseService.updateProviderApprovalStatus(
        providerId,
        AppConstants.statusApproved,
      );

      if (provider != null) {
        await _sendNotification(
          userId: provider.userId,
          title: 'Application Approved',
          message: 'Congratulations! Your provider application has been approved. You can now receive service requests.',
          type: 'provider_approved',
        );
      }

      await loadPendingProviders();
      await loadStatistics();
      Get.snackbar('Success', 'Provider approved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve provider');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> rejectProvider(String providerId) async {
    try {
      isSubmitting.value = true;

      final provider = await firebaseService.getProvider(providerId);

      await firebaseService.updateProviderApprovalStatus(
        providerId,
        AppConstants.statusRejected,
      );

      if (provider != null) {
        await _sendNotification(
          userId: provider.userId,
          title: 'Application Rejected',
          message: 'Your provider application has been rejected. Please update your profile and try again.',
          type: 'provider_rejected',
        );
      }

      await loadPendingProviders();
      await loadStatistics();
      Get.snackbar('Success', 'Provider rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject provider');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> suspendProvider(String providerId) async {
    try {
      isSubmitting.value = true;

      final provider = await firebaseService.getProvider(providerId);

      await firebaseService.updateProviderApprovalStatus(
        providerId,
        AppConstants.statusSuspended,
      );

      if (provider != null) {
        await _sendNotification(
          userId: provider.userId,
          title: 'Account Suspended',
          message: 'Your provider account has been suspended. Contact support for assistance.',
          type: 'provider_suspended',
        );
      }

      await loadAllProviders();
      Get.snackbar('Success', 'Provider suspended');
    } catch (e) {
      Get.snackbar('Error', 'Failed to suspend provider');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> activateProvider(String providerId) async {
    try {
      isSubmitting.value = true;

      final provider = await firebaseService.getProvider(providerId);

      await firebaseService.updateProviderApprovalStatus(
        providerId,
        AppConstants.statusApproved,
      );

      if (provider != null) {
        await _sendNotification(
          userId: provider.userId,
          title: 'Account Activated',
          message: 'Your provider account has been re-activated. You can now receive service requests.',
          type: 'provider_approved',
        );
      }

      await loadAllProviders();
      Get.snackbar('Success', 'Provider activated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to activate provider');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final notification = AppNotification(
        notificationId: const Uuid().v4(),
        userId: userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      );
      await firebaseService.createNotification(notification);
    } catch (e) {
      // Don't block main action if notification fails
    }
  }

  // Category CRUD
  Future<bool> createCategory({
    required String categoryName,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;
      final category = Category(
        categoryId: const Uuid().v4(),
        categoryName: categoryName,
        description: description,
      );
      await firebaseService.createCategory(category);
      await loadCategories();
      Get.snackbar('Success', 'Category created');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create category');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String categoryName,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;
      await firebaseService.updateCategory(categoryId, {
        'categoryName': categoryName,
        'description': description,
      });
      await loadCategories();
      Get.snackbar('Success', 'Category updated');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      isSubmitting.value = true;
      await firebaseService.deleteCategory(categoryId);
      await loadCategories();
      Get.snackbar('Success', 'Category deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category');
    } finally {
      isSubmitting.value = false;
    }
  }

  // User Management
  Future<void> toggleUserStatus(String uid, bool isActive) async {
    try {
      isSubmitting.value = true;
      await firebaseService.updateUser(uid, {'isActive': isActive});
      await loadAllUsers();
      Get.snackbar('Success', 'User status updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user status');
    } finally {
      isSubmitting.value = false;
    }
  }
}
