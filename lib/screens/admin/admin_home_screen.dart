import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/routes.dart';
import '../../models/provider_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late final AdminController adminController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    adminController = Get.find<AdminController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: adminController.loadDashboardData,
        child: Obx(() {
          if (adminController.isLoading.value &&
              adminController.statistics.isEmpty) {
            return const Center(
              child: CustomLoadingIndicator(message: AppStrings.loading),
            );
          }

          return ListView(
            padding: EdgeInsets.all(AppTheme.spacing16),
            children: [
              _buildStatisticsSection(),
              SizedBox(height: AppTheme.spacing24),
              _buildQuickActionsSection(),
              SizedBox(height: AppTheme.spacing24),
              _buildPendingProvidersSection(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final stats = adminController.statistics;
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
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: 'Total Users',
              value: stats['totalUsers']?.toString() ?? '0',
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Approved Providers',
              value: stats['approvedProviders']?.toString() ?? '0',
              icon: Icons.verified_user,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Pending Providers',
              value: stats['pendingProviders']?.toString() ?? '0',
              icon: Icons.pending,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Total Requests',
              value: stats['totalRequests']?.toString() ?? '0',
              icon: Icons.assignment,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _ActionCard(
              title: 'Pending Providers',
              icon: Icons.person_add,
              onTap: () => Get.toNamed(AppRoutes.adminProviderApproval),
            ),
            _ActionCard(
              title: 'All Providers',
              icon: Icons.people,
              onTap: () => Get.toNamed(AppRoutes.adminProviders),
            ),
            _ActionCard(
              title: 'Users',
              icon: Icons.supervised_user_circle,
              onTap: () => Get.toNamed(AppRoutes.adminUsers),
            ),
            _ActionCard(
              title: 'Categories',
              icon: Icons.category,
              onTap: () => Get.toNamed(AppRoutes.adminCategories),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingProvidersSection() {
    final pendingProviders = adminController.pendingProviders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Approvals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (pendingProviders.isNotEmpty)
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.adminProviderApproval),
                child: const Text('View All'),
              ),
          ],
        ),
        SizedBox(height: AppTheme.spacing12),
        if (pendingProviders.isEmpty)
          const EmptyState(
            title: 'No pending approvals',
            message: 'All providers have been reviewed.',
            icon: Icons.check_circle,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingProviders.length > 3 ? 3 : pendingProviders.length,
            itemBuilder: (context, index) {
              final provider = pendingProviders[index];
              return _ProviderApprovalCard(
                provider: provider,
                onApprove: () => adminController.approveProvider(provider.providerId),
                onReject: () => adminController.rejectProvider(provider.providerId),
              );
            },
          ),
      ],
    );
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
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              SizedBox(height: AppTheme.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderApprovalCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ProviderApprovalCard({
    required this.provider,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
                        '${provider.yearsOfExperience} years experience',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              provider.serviceDescription,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.approve,
                    onPressed: onApprove,
                    backgroundColor: Colors.green,
                    height: 36,
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.reject,
                    onPressed: onReject,
                    backgroundColor: Colors.red,
                    height: 36,
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
