import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/provider_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  late final AdminController adminController;
  final authController = AuthController.instance;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    adminController = Get.find<AdminController>();
    adminController.loadAllProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Providers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (adminController.isLoading.value) {
                return const Center(
                  child: CustomLoadingIndicator(message: AppStrings.loading),
                );
              }

              final providers = _filterProviders(adminController.providers);

              if (providers.isEmpty) {
                return const EmptyState(
                  title: 'No providers found',
                  message: 'Try changing the filter.',
                  icon: Icons.person_search,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppTheme.spacing16),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return _ProviderCard(
                    provider: provider,
                    onSuspend: () => _confirmSuspend(provider),
                    onActivate: () => adminController.activateProvider(provider.providerId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacing16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _filterStatus == 'all',
              onTap: () => setState(() => _filterStatus = 'all'),
            ),
            SizedBox(width: AppTheme.spacing8),
            _FilterChip(
              label: 'Approved',
              isSelected: _filterStatus == 'approved',
              onTap: () => setState(() => _filterStatus = 'approved'),
            ),
            SizedBox(width: AppTheme.spacing8),
            _FilterChip(
              label: 'Pending',
              isSelected: _filterStatus == 'pending',
              onTap: () => setState(() => _filterStatus = 'pending'),
            ),
            SizedBox(width: AppTheme.spacing8),
            _FilterChip(
              label: 'Rejected',
              isSelected: _filterStatus == 'rejected',
              onTap: () => setState(() => _filterStatus = 'rejected'),
            ),
            SizedBox(width: AppTheme.spacing8),
            _FilterChip(
              label: 'Suspended',
              isSelected: _filterStatus == 'suspended',
              onTap: () => setState(() => _filterStatus = 'suspended'),
            ),
          ],
        ),
      ),
    );
  }

  List<Provider> _filterProviders(List<Provider> providers) {
    if (_filterStatus == 'all') return providers;
    return providers.where((p) => p.approvalStatus == _filterStatus).toList();
  }

  void _confirmSuspend(Provider provider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Suspend Provider'),
        content: Text('Are you sure you want to suspend ${provider.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              adminController.suspendProvider(provider.providerId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppTheme.spacing8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(right: AppTheme.spacing4),
                  child: Icon(Icons.check, size: 16, color: AppTheme.primaryColor),
                ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  const _ProviderCard({
    required this.provider,
    required this.onSuspend,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(provider.approvalStatus);
    final statusText = _getStatusText(provider.approvalStatus);

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: provider.profilePictureUrl != null
                      ? NetworkImage(provider.profilePictureUrl!)
                      : null,
                  child: provider.profilePictureUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        provider.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
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
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '${provider.averageRating} (${provider.totalReviews} reviews)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(width: AppTheme.spacing16),
                Icon(Icons.work, size: 16, color: AppTheme.textSecondaryColor),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '${provider.yearsOfExperience} years',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            if (provider.approvalStatus == AppConstants.statusApproved)
              CustomButton(
                text: 'Suspend',
                onPressed: onSuspend,
                backgroundColor: Colors.orange,
                height: 36,
              )
            else if (provider.approvalStatus == AppConstants.statusSuspended)
              CustomButton(
                text: 'Activate',
                onPressed: onActivate,
                backgroundColor: Colors.green,
                height: 36,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return Colors.green;
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusRejected:
        return Colors.red;
      case AppConstants.statusSuspended:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return 'Approved';
      case AppConstants.statusPending:
        return 'Pending';
      case AppConstants.statusRejected:
        return 'Rejected';
      case AppConstants.statusSuspended:
        return 'Suspended';
      default:
        return 'Unknown';
    }
  }
}
