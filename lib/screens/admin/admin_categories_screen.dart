import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/category_model.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  late final AdminController adminController;
  final authController = AuthController.instance;

  @override
  void initState() {
    super.initState();
    adminController = Get.find<AdminController>();
    adminController.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
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

        final categories = adminController.categories;

        if (categories.isEmpty) {
          return const EmptyState(
            title: 'No categories found',
            message: 'Create your first service category.',
            icon: Icons.category,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacing16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              onEdit: () => _showEditDialog(category),
              onDelete: () => _confirmDelete(category),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Category Name',
              controller: nameController,
              hint: 'e.g., Electrician',
            ),
            SizedBox(height: AppTheme.spacing12),
            CustomTextField(
              label: 'Description (Optional)',
              controller: descriptionController,
              hint: 'Brief description of the service',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => CustomButton(
            text: AppStrings.save,
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Category name is required');
                return;
              }
              adminController.createCategory(
                categoryName: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );
              Get.back();
            },
            isLoading: adminController.isSubmitting.value,
          )),
        ],
      ),
    );
  }

  void _showEditDialog(Category category) {
    final nameController = TextEditingController(text: category.categoryName);
    final descriptionController =
        TextEditingController(text: category.description ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Category Name',
              controller: nameController,
              hint: 'e.g., Electrician',
            ),
            SizedBox(height: AppTheme.spacing12),
            CustomTextField(
              label: 'Description (Optional)',
              controller: descriptionController,
              hint: 'Brief description of the service',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => CustomButton(
            text: AppStrings.save,
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Category name is required');
                return;
              }
              adminController.updateCategory(
                categoryId: category.categoryId,
                categoryName: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );
              Get.back();
            },
            isLoading: adminController.isSubmitting.value,
          )),
        ],
      ),
    );
  }

  void _confirmDelete(Category category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete ${category.categoryName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              adminController.deleteCategory(category.categoryId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
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
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                  ),
                  child: Icon(Icons.category, color: AppTheme.primaryColor),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (category.description != null) ...[
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          category.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
