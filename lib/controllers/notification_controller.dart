import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/app_notification_model.dart';
import '../services/firebase_service.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final firebaseService = FirebaseService.instance;
  final authController = AuthController.instance;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final userId = authController.appUser.value?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final list = await firebaseService.getUserNotifications(userId);
      notifications.assignAll(list);
      unreadCount.value = await firebaseService.getUnreadNotificationCount(userId);
    } catch (e) {
      // Silent fail
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await firebaseService.markNotificationAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
      }
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> markAllAsRead() async {
    final userId = authController.appUser.value?.uid;
    if (userId == null) return;

    try {
      await firebaseService.markAllNotificationsAsRead(userId);
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
      unreadCount.value = 0;
    } catch (e) {
      // Silent fail
    }
  }
}
