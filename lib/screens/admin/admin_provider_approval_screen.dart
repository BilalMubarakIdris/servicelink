import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/provider_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AdminProviderApprovalScreen extends StatefulWidget {
  const AdminProviderApprovalScreen({super.key});

  @override
  State<AdminProviderApprovalScreen> createState() =>
      _AdminProviderApprovalScreenState();
}

class _AdminProviderApprovalScreenState
    extends State<AdminProviderApprovalScreen> {
  late final AdminController adminController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    adminController = Get.find<AdminController>();
    adminController.loadPendingProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (adminController.isLoading.value) {
          return const Center(
            child: CustomLoadingIndicator(message: AppStrings.loading),
          );
        }

        final pendingProviders = adminController.pendingProviders;

        if (pendingProviders.isEmpty) {
          return const EmptyState(
            title: 'No pending approvals',
            message: 'All providers have been reviewed.',
            icon: Icons.check_circle,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing16),
          itemCount: pendingProviders.length,
          itemBuilder: (context, index) {
            final provider = pendingProviders[index];
            return _ProviderDetailCard(
              provider: provider,
              onApprove: () => _confirmApprove(provider),
              onReject: () => _confirmReject(provider),
            );
          },
        );
      }),
    );
  }

  void _confirmApprove(Provider provider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Approve Provider'),
        content: Text('Are you sure you want to approve ${provider.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              adminController.approveProvider(provider.providerId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(Provider provider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Provider'),
        content: Text('Are you sure you want to reject ${provider.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              adminController.rejectProvider(provider.providerId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _ProviderDetailCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ProviderDetailCard({
    required this.provider,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: provider.profilePictureUrl != null
                      ? NetworkImage(provider.profilePictureUrl!)
                      : null,
                  child: provider.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 32)
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
                        provider.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        provider.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing16),
            _InfoRow(
              label: 'Experience',
              value: '${provider.yearsOfExperience} years',
              icon: Icons.work,
            ),
            SizedBox(height: AppTheme.spacing8),
            _InfoRow(
              label: 'Location',
              value: '${provider.state}, ${provider.localGovernmentArea}',
              icon: Icons.location_on,
            ),
            SizedBox(height: AppTheme.spacing8),
            _InfoRow(
              label: 'Address',
              value: provider.address,
              icon: Icons.place,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Service Description',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              provider.serviceDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppTheme.spacing16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.approve,
                    onPressed: onApprove,
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.reject,
                    onPressed: onReject,
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
        SizedBox(width: AppTheme.spacing8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
