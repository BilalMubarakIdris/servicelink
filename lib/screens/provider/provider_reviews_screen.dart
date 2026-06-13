import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/provider_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/provider_model.dart';
import '../../models/review_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({super.key});

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  late final ProviderController providerController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    providerController = Get.find<ProviderController>();
    providerController.loadProviderReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Obx(() {
        final provider = providerController.currentProvider.value;
        final reviews = providerController.reviews;

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
          onRefresh: providerController.loadProviderReviews,
          child: ListView(
            padding: EdgeInsets.all(AppTheme.spacing16),
            children: [
              _buildRatingSummary(provider),
              SizedBox(height: AppTheme.spacing24),
              _buildReviewsList(reviews),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRatingSummary(Provider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          children: [
            Text(
              'Average Rating',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                SizedBox(width: AppTheme.spacing8),
                StarRatingDisplay(
                  rating: provider.averageRating,
                  size: 32,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              '${provider.totalReviews} reviews',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const EmptyState(
        title: 'No reviews yet',
        message: 'You will see customer reviews here once you complete services.',
        icon: Icons.star_border,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _ReviewCard(review: review);
          },
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

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
                  radius: 20,
                  child: Icon(Icons.person, size: 20),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StarRatingDisplay(
                  rating: review.rating,
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
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
