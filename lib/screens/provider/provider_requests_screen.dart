import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/provider_controller.dart';
import '../../models/service_request_model.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  late final ProviderController providerController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    providerController = Get.find<ProviderController>();
  }

  List<ServiceRequest> get _filteredRequests {
    if (_selectedFilter == 'all') return providerController.requests;
    return providerController.requests
        .where((r) => r.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requests'),
      ),
      body: Obx(() {
        final requests = _filteredRequests;

        return Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: requests.isEmpty
                  ? const EmptyState(
                      title: 'No requests found',
                      message: 'No requests match this filter.',
                      icon: Icons.inbox,
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      itemCount: requests.length,
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
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      child: Row(
        children: [
          _FilterChip('All', 'all'),
          SizedBox(width: AppTheme.spacing8),
          _FilterChip('Pending', AppConstants.requestPending),
          SizedBox(width: AppTheme.spacing8),
          _FilterChip('Accepted', AppConstants.requestAccepted),
          SizedBox(width: AppTheme.spacing8),
          _FilterChip('In Progress', AppConstants.requestInProgress),
          SizedBox(width: AppTheme.spacing8),
          _FilterChip('Completed', AppConstants.requestCompleted),
          SizedBox(width: AppTheme.spacing8),
          _FilterChip('Rejected', AppConstants.requestRejected),
        ],
      ),
    );
  }

  Widget _FilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
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
    final requestId = request.requestId;

    final isTerminal = request.status == AppConstants.requestRejected ||
        request.status == AppConstants.requestCancelled;
    final step = _statusStep(request.status);

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
            SizedBox(height: AppTheme.spacing8),
            Text(
              _formatDate(request.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              request.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            if (isTerminal) ...[
              SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Icon(
                    request.status == AppConstants.requestRejected
                        ? Icons.cancel
                        : Icons.info_outline,
                    size: 16,
                    color: statusColor,
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    request.status == AppConstants.requestRejected
                        ? 'You rejected this request'
                        : 'This request was cancelled by the user',
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ],
              ),
            ],
            if (!isTerminal) ...[
              SizedBox(height: AppTheme.spacing16),
              _buildProgressStepper(step),
            ],
            SizedBox(height: AppTheme.spacing12),
            _buildActionButtons(request.status, requestId),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Widget _buildActionButtons(String status, String requestId) {
    final providerController = ProviderController.instance;

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
