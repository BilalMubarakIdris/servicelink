import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late final UserController userController;
  final authController = AuthController.instance;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          _buildNotificationBell(),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My Requests',
            onPressed: () => Get.toNamed(AppRoutes.serviceRequests),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'My Profile',
            onPressed: () => Get.toNamed(AppRoutes.userProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: authController.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: userController.loadHomeData,
        child: Obx(() {
          if (userController.isLoading.value &&
              userController.providers.isEmpty) {
            return ListView(
              children: const [
                SizedBox(
                  height: 300,
                  child: CustomLoadingIndicator(message: AppStrings.loading),
                ),
              ],
            );
          }

          return ListView(
            padding: EdgeInsets.all(AppTheme.spacing16),
            children: [
              Text(
                'Hello, ${authController.appUser.value?.fullName ?? 'User'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: AppTheme.spacing8),
              Text(
                AppStrings.welcomeDesc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppTheme.spacing24),
              CustomTextField(
                label: AppStrings.searchProviders,
                hint: 'Search by name or service',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) {
                  if (value.isEmpty) {
                    userController.searchProviders('');
                  }
                },
              ),
              SizedBox(height: AppTheme.spacing12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      userController.searchProviders(_searchController.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
              SizedBox(height: AppTheme.spacing16),
              Text(
                AppStrings.categories,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppTheme.spacing12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: userController.selectedCategoryId.isEmpty,
                      onTap: () => userController.filterByCategory(null),
                    ),
                    ...userController.categories.map(
                      (category) => _CategoryChip(
                        label: category.categoryName,
                        isSelected:
                            userController.selectedCategoryId.value ==
                            category.categoryId,
                        onTap: () =>
                            userController.filterByCategory(category.categoryId),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing24),
              Text(
                AppStrings.nearbyProviders,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppTheme.spacing12),
              if (userController.providers.isEmpty)
                EmptyState(
                  title: AppStrings.noData,
                  message: 'No approved providers found. Try another category.',
                  icon: Icons.person_search,
                  onRetry: userController.loadHomeData,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: userController.providers.length,
                  itemBuilder: (context, index) {
                    final provider = userController.providers[index];
                    return ProviderCard(
                      name: provider.fullName,
                      category: userController.categoryName(provider.categoryId),
                      rating: provider.averageRating,
                      reviews: provider.totalReviews,
                      experience: '${provider.yearsOfExperience}',
                      imageUrl: provider.profilePictureUrl,
                      onTap: () => Get.toNamed(
                        AppRoutes.providerDetail,
                        arguments: provider,
                      ),
                    );
                  },
                ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(color: Colors.grey.withValues(alpha: 0.3)),
            SizedBox(height: AppTheme.spacing8),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              'Created by Hussain Muhammad Bello',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
            ),
            Text(
              'Reg. No.: 221030682',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
