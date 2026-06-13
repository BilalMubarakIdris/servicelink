import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/auth_controller.dart';
import '../models/category_model.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';
import '../models/service_request_model.dart';
import '../models/app_notification_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class ProviderController extends GetxController {
  static ProviderController get instance => Get.find();

  final firebaseService = FirebaseService.instance;
  final authController = AuthController.instance;

  final Rx<Provider?> currentProvider = Rx<Provider?>(null);
  final RxList<ServiceRequest> requests = <ServiceRequest>[].obs;
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Category> categories = <Category>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString processingRequestId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProviderData();
    loadCategories();
  }

  Future<void> loadProviderData() async {
    final uid = authController.appUser.value?.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;
      final provider = await firebaseService.getProviderByUserId(uid);
      currentProvider.value = provider;

      if (provider != null &&
          provider.approvalStatus == AppConstants.statusApproved) {
        await Future.wait([loadProviderRequests(), loadProviderReviews()]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load provider data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProviderRequests() async {
    final provider = currentProvider.value;
    if (provider == null) return;

    try {
      isLoading.value = true;
      final list = await firebaseService.getProviderRequests(
        provider.providerId,
      );
      requests.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProviderReviews() async {
    final provider = currentProvider.value;
    if (provider == null) return;

    try {
      final list = await firebaseService.getProviderReviews(
        provider.providerId,
      );
      reviews.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reviews');
    }
  }

  Future<void> loadCategories() async {
    try {
      final list = await firebaseService.getCategories();
      categories.assignAll(
        list.isEmpty ? AppConstants.defaultCategories : list,
      );
    } catch (e) {
      categories.assignAll(AppConstants.defaultCategories);
    }
  }

  // Request Management
  Future<void> acceptRequest(ServiceRequest request) async {
    final provider = currentProvider.value;

    if (provider == null) return;

    if (processingRequestId.value.isNotEmpty) {
      Get.snackbar('Info', 'Please wait for the current action to complete');
      return;
    }

    try {
      processingRequestId.value = request.requestId;

      await firebaseService.updateServiceRequest(request.requestId, {
        'status': AppConstants.requestAccepted,
        'acceptedAt': DateTime.now(),
      });

      await _sendNotification(
        userId: request.userId,
        title: 'Request Accepted',
        message: '${provider.fullName} has accepted your service request.',
        type: 'request_accepted',
        requestId: request.requestId,
      );

      await loadProviderRequests();
      Get.snackbar('Success', 'Request accepted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept: $e');
    } finally {
      processingRequestId.value = '';
    }
  }

  Future<void> rejectRequest(ServiceRequest request) async {
    if (request.status != AppConstants.requestPending) {
      Get.snackbar('Info', 'This request can no longer be rejected');
      return;
    }

    if (processingRequestId.value.isNotEmpty) {
      Get.snackbar('Info', 'Please wait for the current action to complete');
      return;
    }

    try {
      processingRequestId.value = request.requestId;
      await firebaseService.updateServiceRequest(request.requestId, {
        'status': AppConstants.requestRejected,
      });

      final provider = currentProvider.value;
      if (provider != null) {
        await _sendNotification(
          userId: request.userId,
          title: 'Request Rejected',
          message: '${provider.fullName} has rejected your service request.',
          type: 'request_rejected',
          requestId: request.requestId,
        );
      }

      await loadProviderRequests();
      Get.snackbar('Success', 'Request rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject: $e');
    } finally {
      processingRequestId.value = '';
    }
  }

  Future<void> startRequest(ServiceRequest request) async {
    if (request.status != AppConstants.requestAccepted) {
      Get.snackbar('Info', 'This service cannot be started yet');
      return;
    }

    if (processingRequestId.value.isNotEmpty) {
      Get.snackbar('Info', 'Please wait for the current action to complete');
      return;
    }

    try {
      processingRequestId.value = request.requestId;
      await firebaseService.updateServiceRequest(request.requestId, {
        'status': AppConstants.requestInProgress,
      });

      final provider = currentProvider.value;
      if (provider != null) {
        await _sendNotification(
          userId: request.userId,
          title: 'Service Started',
          message: '${provider.fullName} has started working on your request.',
          type: 'request_started',
          requestId: request.requestId,
        );
      }

      await loadProviderRequests();
      Get.snackbar('Success', 'Service started');
    } catch (e) {
      Get.snackbar('Error', 'Failed to start: $e');
    } finally {
      processingRequestId.value = '';
    }
  }

  Future<void> completeRequest(ServiceRequest request) async {
    if (request.status != AppConstants.requestInProgress) {
      Get.snackbar('Info', 'This service is not in progress');
      return;
    }

    if (processingRequestId.value.isNotEmpty) {
      Get.snackbar('Info', 'Please wait for the current action to complete');
      return;
    }

    try {
      processingRequestId.value = request.requestId;
      await firebaseService.updateServiceRequest(request.requestId, {
        'status': AppConstants.requestCompleted,
        'completedAt': DateTime.now(),
      });

      final provider = currentProvider.value;
      if (provider != null) {
        await _sendNotification(
          userId: request.userId,
          title: 'Service Completed',
          message: '${provider.fullName} has completed your service request.',
          type: 'request_completed',
          requestId: request.requestId,
        );
      }

      await loadProviderRequests();
      Get.snackbar('Success', 'Service completed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete: $e');
    } finally {
      processingRequestId.value = '';
    }
  }

  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String requestId,
  }) async {
    try {
      final notification = AppNotification(
        notificationId: const Uuid().v4(),
        userId: userId,
        title: title,
        message: message,
        type: type,
        requestId: requestId,
        createdAt: DateTime.now(),
      );
      await firebaseService.createNotification(notification);
    } catch (e) {
      // Don't block the main action if notification fails
    }
  }

  // Profile Update
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String categoryId,
    required int yearsOfExperience,
    required String serviceDescription,
    required String state,
    required String lga,
    required String address,
    required double latitude,
    required double longitude,
    String? profileImagePath,
  }) async {
    final provider = currentProvider.value;
    if (provider == null) {
      Get.snackbar('Error', 'Provider data not loaded. Please try again.');
      return false;
    }

    try {
      isSubmitting.value = true;

      String? profilePictureUrl = provider.profilePictureUrl;
      if (profileImagePath != null) {
        profilePictureUrl = await firebaseService.uploadProfilePicture(
          profileImagePath,
          provider.userId,
        );
      }

      await firebaseService.updateProvider(provider.providerId, {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'categoryId': categoryId,
        'yearsOfExperience': yearsOfExperience,
        'serviceDescription': serviceDescription,
        'state': state,
        'localGovernmentArea': lga,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'profilePictureUrl': profilePictureUrl,
      });

      // Also update user profile
      await firebaseService.updateUser(provider.userId, {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profilePictureUrl': profilePictureUrl,
      });

      await loadProviderData();
      Get.snackbar('Success', 'Profile updated');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  String getCategoryName(String categoryId) {
    return categories
            .firstWhereOrNull((c) => c.categoryId == categoryId)
            ?.categoryName ??
        'Unknown';
  }

  String getRequestStatusText(String status) {
    switch (status) {
      case AppConstants.requestPending:
        return 'Pending';
      case AppConstants.requestAccepted:
        return 'Accepted';
      case AppConstants.requestRejected:
        return 'Rejected';
      case AppConstants.requestInProgress:
        return 'In Progress';
      case AppConstants.requestCompleted:
        return 'Completed';
      case AppConstants.requestCancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color getRequestStatusColor(String status) {
    switch (status) {
      case AppConstants.requestPending:
        return Get.theme.colorScheme.primary;
      case AppConstants.requestAccepted:
        return Get.theme.colorScheme.secondary;
      case AppConstants.requestRejected:
        return Get.theme.colorScheme.error;
      case AppConstants.requestInProgress:
        return Get.theme.colorScheme.tertiary;
      case AppConstants.requestCompleted:
        return Get.theme.colorScheme.primary;
      case AppConstants.requestCancelled:
        return Get.theme.colorScheme.error;
      default:
        return Get.theme.colorScheme.onSurface;
    }
  }
}
