import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/themes.dart';

class SignUpTypeScreen extends StatelessWidget {
  const SignUpTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Account Type'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What type of account do you want to create?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing32),
            // User Account Option
            _buildAccountTypeCard(
              context,
              icon: Icons.person,
              title: 'User Account',
              description: 'Find and hire service providers',
              onTap: () => Get.toNamed('/signup-user'),
            ),
            SizedBox(height: AppTheme.spacing16),
            // Provider Account Option
            _buildAccountTypeCard(
              context,
              icon: Icons.business,
              title: 'Service Provider Account',
              description: 'Offer your services to clients',
              onTap: () => Get.toNamed('/signup-provider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 30),
              ),
              SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
