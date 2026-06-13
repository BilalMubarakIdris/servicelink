import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../controllers/user_controller.dart';
import '../../models/provider_model.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  late final Provider provider;
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    provider = Get.arguments as Provider;
    userController = Get.find<UserController>();
    userController.loadProviderReviews(provider.providerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.backgroundColor,
                backgroundImage: provider.profilePictureUrl != null
                    ? NetworkImage(provider.profilePictureUrl!)
                    : null,
                child: provider.profilePictureUrl == null
                    ? const Icon(Icons.person, size: 56)
                    : null,
              ),
            ),
            SizedBox(height: AppTheme.spacing16),
            Center(
              child: Text(
                provider.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Center(
              child: Text(
                userController.categoryName(provider.categoryId),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    '${provider.averageRating.toStringAsFixed(1)} (${provider.totalReviews} reviews)',
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing24),
            _InfoTile(
              icon: Icons.work,
              label: AppStrings.yearsOfExperience,
              value: '${provider.yearsOfExperience} years',
            ),
            _InfoTile(
              icon: Icons.phone,
              label: AppStrings.phoneNumber,
              value: provider.phoneNumber,
            ),
            _InfoTile(
              icon: Icons.location_on,
              label: AppStrings.address,
              value:
                  '${provider.address}, ${provider.localGovernmentArea}, ${provider.state}',
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              AppStrings.serviceDescription,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              provider.serviceDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: AppTheme.spacing24),
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.spacing12),
            Obx(() {
              if (userController.reviews.isEmpty) {
                return Text(
                  'No reviews yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }

              return Column(
                children: userController.reviews
                    .take(5)
                    .map(
                      (review) => Card(
                        margin: EdgeInsets.only(bottom: AppTheme.spacing8),
                        child: ListTile(
                          leading: const Icon(Icons.star, color: Colors.orange),
                          title: Text('${review.rating}/5'),
                          subtitle: Text(review.comment),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
            SizedBox(height: AppTheme.spacing24),
            CustomButton(
              text: 'Request Service',
              onPressed: () => Get.toNamed(
                AppRoutes.createRequest,
                arguments: provider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
