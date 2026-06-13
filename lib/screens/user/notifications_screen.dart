import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../models/app_notification_model.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    notificationController = Get.find<NotificationController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (notificationController.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: () => notificationController.markAllAsRead(),
              child: const Text('Mark all read'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (notificationController.isLoading.value) {
          return const Center(
            child: CustomLoadingIndicator(message: 'Loading notifications...'),
          );
        }

        final notifications = notificationController.notifications;

        if (notifications.isEmpty) {
          return const EmptyState(
            title: 'No notifications',
            message: 'You will see notifications here when providers respond to your requests.',
            icon: Icons.notifications_none,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationCard(
              notification: notification,
              onTap: () {
                if (!notification.isRead) {
                  notificationController.markAsRead(notification.notificationId);
                }
              },
            );
          },
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_rejected':
        return Icons.cancel;
      case 'request_completed':
        return Icons.done_all;
      case 'request_started':
        return Icons.play_circle;
      case 'provider_approved':
        return Icons.verified;
      case 'provider_rejected':
        return Icons.block;
      case 'provider_suspended':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case 'request_accepted':
        return Colors.green;
      case 'request_rejected':
        return Colors.red;
      case 'request_completed':
        return Colors.blue;
      case 'request_started':
        return Colors.orange;
      case 'provider_approved':
        return Colors.green;
      case 'provider_rejected':
        return Colors.red;
      case 'provider_suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      color: notification.isRead ? null : color.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: color, size: 24),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
