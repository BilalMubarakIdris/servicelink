import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/service_request_model.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class UserRequestsScreen extends StatefulWidget {
  const UserRequestsScreen({super.key});

  @override
  State<UserRequestsScreen> createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends State<UserRequestsScreen> {
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    userController.loadUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: Obx(() {
        if (userController.isLoading.value && userController.requests.isEmpty) {
          return const CustomLoadingIndicator(message: AppStrings.loading);
        }

        if (userController.requests.isEmpty) {
          return EmptyState(
            title: AppStrings.noData,
            message: 'You have not submitted any service requests yet.',
            icon: Icons.assignment,
            onRetry: userController.loadUserRequests,
          );
        }

        return RefreshIndicator(
          onRefresh: userController.loadUserRequests,
          child: ListView.separated(
            padding: EdgeInsets.all(AppTheme.spacing16),
            itemCount: userController.requests.length,
            separatorBuilder: (_, _) => SizedBox(height: AppTheme.spacing12),
            itemBuilder: (context, index) {
              final request = userController.requests[index];
              return _RequestCard(
                request: request,
                categoryName: userController.categoryName(request.categoryId),
                onCancel: () => userController.cancelRequest(request),
                onReview: () => _showReviewDialog(request),
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _showReviewDialog(ServiceRequest request) async {
    final commentController = TextEditingController();
    double rating = 5;

    await Get.dialog(
      AlertDialog(
        title: const Text('Rate Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(
              initialRating: 5,
              onRatingUpdate: (value) => rating = value,
            ),
            SizedBox(height: AppTheme.spacing16),
            CustomTextField(
              label: 'Comment',
              hint: 'Share your experience',
              controller: commentController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          Obx(
            () => TextButton(
              onPressed: userController.isSubmitting.value
                  ? null
                  : () async {
                      final success = await userController.submitReview(
                        providerId: request.providerId,
                        requestId: request.requestId,
                        rating: rating,
                        comment: commentController.text.trim(),
                      );
                      if (success) {
                        Get.back();
                        Get.snackbar('Success', 'Review submitted successfully');
                      }
                    },
              child: userController.isSubmitting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.submit),
            ),
          ),
        ],
      ),
    );

    commentController.dispose();
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final String categoryName;
  final VoidCallback onCancel;
  final VoidCallback onReview;

  const _RequestCard({
    required this.request,
    required this.categoryName,
    required this.onCancel,
    required this.onReview,
  });

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.requestAccepted:
      case AppConstants.requestCompleted:
        return AppTheme.successColor;
      case AppConstants.requestRejected:
      case AppConstants.requestCancelled:
        return AppTheme.errorColor;
      case AppConstants.requestInProgress:
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _statusText(String status) {
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
        return status;
    }
  }

  int _statusStep(String status) {
    switch (status) {
      case AppConstants.requestPending:
        return 0;
      case AppConstants.requestAccepted:
        return 1;
      case AppConstants.requestInProgress:
        return 2;
      case AppConstants.requestCompleted:
        return 3;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTerminal = request.status == AppConstants.requestRejected ||
        request.status == AppConstants.requestCancelled;
    final step = _statusStep(request.status);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                  ),
                  child: Text(
                    _statusText(request.status),
                    style: TextStyle(
                      color: _statusColor(request.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(request.description),
            if (request.budget != null) ...[
              SizedBox(height: AppTheme.spacing4),
              Text(
                'Budget: \$${request.budget}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (isTerminal) ...[
              SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Icon(
                    request.status == AppConstants.requestRejected
                        ? Icons.cancel
                        : Icons.info_outline,
                    size: 16,
                    color: _statusColor(request.status),
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    request.status == AppConstants.requestRejected
                        ? 'Your request was rejected by the provider'
                        : 'You cancelled this request',
                    style: TextStyle(
                      color: _statusColor(request.status),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (!isTerminal) ...[
              SizedBox(height: AppTheme.spacing16),
              _buildProgressStepper(step),
            ],
            SizedBox(height: AppTheme.spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status == AppConstants.requestPending)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(AppStrings.cancel),
                  ),
                if (request.status == AppConstants.requestCompleted)
                  TextButton(
                    onPressed: onReview,
                    child: const Text('Leave Review'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper(int currentStep) {
    final steps = ['Pending', 'Accepted', 'In Progress', 'Completed'];
    final icons = [
      Icons.schedule,
      Icons.check_circle,
      Icons.play_circle,
      Icons.done_all,
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppTheme.primaryColor
                          : Colors.grey.withValues(alpha: 0.2),
                      border: isCurrent
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icons[index],
                      size: 16,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppTheme.primaryColor : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: AppTheme.spacing4),
        Row(
          children: List.generate(steps.length - 1, (index) {
            final isActive = index < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                color: isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
