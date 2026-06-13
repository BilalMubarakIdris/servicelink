import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/provider_model.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  late final Provider provider;
  late final UserController userController;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _preferredDateController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Get.arguments as Provider;
    userController = Get.find<UserController>();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _preferredDateController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await userController.submitServiceRequest(
      provider: provider,
      description: _descriptionController.text.trim(),
      preferredDate: _preferredDateController.text.trim().isEmpty
          ? null
          : _preferredDateController.text.trim(),
      budget: double.tryParse(_budgetController.text.trim()),
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Get.snackbar(
        'Request Sent',
        'Your service request has been sent to ${provider.fullName}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Service')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requesting ${provider.fullName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppTheme.spacing24),
              CustomTextField(
                label: 'Service Description',
                hint: 'Describe the service you need',
                controller: _descriptionController,
                maxLines: 4,
                prefixIcon: const Icon(Icons.description),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spacing16),
              CustomTextField(
                label: 'Preferred Date (optional)',
                hint: 'e.g. Tomorrow, 15 June',
                controller: _preferredDateController,
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              SizedBox(height: AppTheme.spacing16),
              CustomTextField(
                label: 'Budget (optional)',
                hint: 'Enter amount',
                controller: _budgetController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              SizedBox(height: AppTheme.spacing32),
              Obx(
                () => CustomButton(
                  text: AppStrings.submit,
                  onPressed: _submit,
                  isLoading: userController.isSubmitting.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
