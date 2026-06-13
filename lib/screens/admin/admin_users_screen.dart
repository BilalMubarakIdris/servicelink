import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminController adminController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    adminController = Get.find<AdminController>();
    adminController.loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
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

        final users = adminController.users;

        if (users.isEmpty) {
          return const EmptyState(
            title: 'No users found',
            message: 'There are no registered users yet.',
            icon: Icons.people,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(
              user: user,
              onToggleStatus: () => adminController.toggleUserStatus(
                user.uid,
                !user.isActive,
              ),
            );
          },
        );
      }),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onToggleStatus;

  const _UserCard({
    required this.user,
    required this.onToggleStatus,
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
                  backgroundImage: user.profilePictureUrl != null
                      ? NetworkImage(user.profilePictureUrl!)
                      : null,
                  child: user.profilePictureUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user.email,
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
                    color: user.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    border: Border.all(
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
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
                Icon(Icons.phone, size: 16, color: AppTheme.textSecondaryColor),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  user.phoneNumber,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(width: AppTheme.spacing16),
                Icon(Icons.badge, size: 16, color: AppTheme.textSecondaryColor),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  user.role.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  'Joined: ${_formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            CustomButton(
              text: user.isActive ? 'Deactivate' : 'Activate',
              onPressed: onToggleStatus,
              backgroundColor: user.isActive ? Colors.red : Colors.green,
              height: 36,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
