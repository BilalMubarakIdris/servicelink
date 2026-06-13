import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/provider_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/routes.dart';
import '../../models/provider_model.dart';
import '../../models/service_request_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  late final ProviderController providerController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    providerController = Get.find<ProviderController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        actions: [
          _buildNotificationBell(),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'My Reviews',
            onPressed: () => Get.toNamed(AppRoutes.providerReviews),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () => Get.toNamed(AppRoutes.providerProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Obx(() {
        final provider = providerController.currentProvider.value;
        final requests = providerController.requests;

        if (providerController.isLoading.value && provider == null) {
          return const Center(
            child: CustomLoadingIndicator(message: AppStrings.loading),
          );
        }

        if (provider == null) {
          return const EmptyState(
            title: 'No provider profile',
            message: 'Please complete your provider profile.',
            icon: Icons.person_off,
          );
        }

        return RefreshIndicator(
          onRefresh: providerController.loadProviderData,
          child: ListView(
            padding: EdgeInsets.all(AppTheme.spacing16),
            children: [
              _buildProviderHeader(provider),
              SizedBox(height: AppTheme.spacing24),
              _buildStatsSection(provider),
              SizedBox(height: AppTheme.spacing24),
              _buildRequestsSection(requests),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProviderHeader(Provider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: provider.profilePictureUrl != null
                  ? NetworkImage(provider.profilePictureUrl!)
                  : null,
              child: provider.profilePictureUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    provider.serviceDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Provider provider) {
    final pendingRequests = providerController.requests
        .where((r) => r.status == AppConstants.requestPending)
        .length;
    final activeRequests = providerController.requests
        .where((r) => r.status == AppConstants.requestAccepted ||
                     r.status == AppConstants.requestInProgress)
        .length;
    final completedRequests = providerController.requests
        .where((r) => r.status == AppConstants.requestCompleted)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _StatCard(
              title: 'Pending',
              value: pendingRequests.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Active',
              value: activeRequests.toString(),
              icon: Icons.work,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Completed',
              value: completedRequests.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestsSection(List<ServiceRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (requests.isNotEmpty)
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.providerRequests),
                child: const Text('View All'),
              ),
          ],
        ),
        SizedBox(height: AppTheme.spacing12),
        if (requests.isEmpty)
          const EmptyState(
            title: 'No requests yet',
            message: 'You will see service requests here when users contact you.',
            icon: Icons.inbox,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length > 5 ? 5 : requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(
                request: request,
                onAccept: () => providerController.acceptRequest(request),
                onReject: () => providerController.rejectRequest(request),
                onStart: () => providerController.startRequest(request),
                onComplete: () => providerController.completeRequest(request),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNotificationBell() {
    final notificationController = Get.find<NotificationController>();
    return Obx(() {
      final count = notificationController.unreadCount.value;
      return IconButton(
        icon: Badge(
          isLabelVisible: count > 0,
          label: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          child: const Icon(Icons.notifications),
        ),
        tooltip: 'Notifications',
        onPressed: () => Get.toNamed(AppRoutes.notifications),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            SizedBox(height: AppTheme.spacing8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final providerController = ProviderController.instance;
    final statusColor = providerController.getRequestStatusColor(request.status);
    final statusText = providerController.getRequestStatusText(request.status);

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Request',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              request.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (request.budget != null || request.preferredDate != null) ...[
              SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  if (request.budget != null) ...[
                    Icon(Icons.attach_money, size: 16, color: AppTheme.textSecondaryColor),
                    SizedBox(width: AppTheme.spacing4),
                    Text(
                      'Budget: \$${request.budget}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (request.preferredDate != null) ...[
                    SizedBox(width: AppTheme.spacing16),
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                    SizedBox(width: AppTheme.spacing4),
                    Text(
                      request.preferredDate!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
            SizedBox(height: AppTheme.spacing12),
            _buildActionButtons(request.status),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    final providerController = ProviderController.instance;
    final requestId = request.requestId;

    if (status == AppConstants.requestPending) {
      return Obx(() {
        final isProcessing = providerController.processingRequestId.value == requestId;
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.accept,
                onPressed: isProcessing ? () {} : onAccept,
                isLoading: isProcessing,
                backgroundColor: Colors.green,
                height: 36,
              ),
            ),
            SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: CustomButton(
                text: AppStrings.reject,
                onPressed: isProcessing ? () {} : onReject,
                backgroundColor: Colors.red,
                height: 36,
              ),
            ),
          ],
        );
      });
    } else if (status == AppConstants.requestAccepted) {
      return Obx(() {
        final isProcessing = providerController.processingRequestId.value == requestId;
        return CustomButton(
          text: 'Start Service',
          onPressed: isProcessing ? () {} : onStart,
          isLoading: isProcessing,
          backgroundColor: Colors.blue,
          height: 36,
        );
      });
    } else if (status == AppConstants.requestInProgress) {
      return Obx(() {
        final isProcessing = providerController.processingRequestId.value == requestId;
        return CustomButton(
          text: AppStrings.complete,
          onPressed: isProcessing ? () {} : onComplete,
          isLoading: isProcessing,
          backgroundColor: Colors.green,
          height: 36,
        );
      });
    } else {
      return const SizedBox.shrink();
    }
  }
}
