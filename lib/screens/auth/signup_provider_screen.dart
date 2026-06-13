import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import '../../controllers/auth_controller.dart';
import '../../models/category_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class SignUpProviderScreen extends StatefulWidget {
  const SignUpProviderScreen({super.key});

  @override
  State<SignUpProviderScreen> createState() => _SignUpProviderScreenState();
}

class _SignUpProviderScreenState extends State<SignUpProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final firebaseService = FirebaseService.instance;

  // Step 1: Basic Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Professional Info
  String? _selectedCategory;
  final _yearsExperienceController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();

  // Step 3: Location
  final _stateController = TextEditingController();
  final _lgaController = TextEditingController();
  final _addressController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  int _currentStep = 0;
  List<Category> _categories = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final categories = await firebaseService.getCategories();
      setState(() {
        _categories = categories.isEmpty ? AppConstants.defaultCategories : categories;
      });
    } catch (e) {
      setState(() {
        _categories = AppConstants.defaultCategories;
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission', 'Location permission is required');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      Get.snackbar('Success', 'Location retrieved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void _handleSignUp() async {
    if (_currentStep == 2 && _formKey.currentState!.validate()) {
      authController.registerProvider(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        categoryId: _selectedCategory!,
        yearsOfExperience: int.tryParse(_yearsExperienceController.text) ?? 0,
        serviceDescription: _serviceDescriptionController.text.trim(),
        state: _stateController.text.trim(),
        lga: _lgaController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        profileImagePath: _profileImagePath,
      );
    } else if (_currentStep < 2) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _yearsExperienceController.dispose();
    _serviceDescriptionController.dispose();
    _stateController.dispose();
    _lgaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Provider Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Step Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStepIndicator(0, 'Basic Info'),
                    _buildStepIndicator(1, 'Professional'),
                    _buildStepIndicator(2, 'Location'),
                  ],
                ),
                SizedBox(height: AppTheme.spacing32),
                // Step Content
                if (_currentStep == 0) _buildBasicInfoStep(),
                if (_currentStep == 1) _buildProfessionalInfoStep(),
                if (_currentStep == 2) _buildLocationStep(),
                SizedBox(height: AppTheme.spacing32),
                // Navigation Buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          child: Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Obx(
                        () => CustomButton(
                          text: _currentStep == 2
                              ? AppStrings.submit
                              : AppStrings.next,
                          onPressed: _handleSignUp,
                          isLoading: authController.isLoading.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : AppTheme.backgroundColor,
            border: Border.all(
              color: isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.fullName,
          hint: 'Enter your full name',
          controller: _fullNameController,
          prefixIcon: Icon(Icons.person),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Full name is required';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.email,
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!value!.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.phoneNumber,
          hint: 'Enter your phone number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(Icons.phone),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Phone number is required';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.password,
          hint: 'Enter your password',
          controller: _passwordController,
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            child: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Password is required';
            if (value!.length < AppConstants.minPasswordLength) {
              return 'Password must be at least ${AppConstants.minPasswordLength} characters';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.confirmPassword,
          hint: 'Confirm your password',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            child: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please confirm your password';
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        // Profile Picture
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: _profileImagePath != null
                ? (kIsWeb
                    ? Image.network(_profileImagePath!, fit: BoxFit.cover)
                    : Image.file(File(_profileImagePath!), fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: AppTheme.spacing8),
                      Text('Tap to select photo'),
                    ],
                  ),
          ),
        ),
        SizedBox(height: AppTheme.spacing16),
        // Category Dropdown
        CustomDropdown<String>(
          label: AppStrings.serviceCategory,
          value: _selectedCategory,
          prefixIcon: const Icon(Icons.category),
          items: _categories
              .map(
                (category) => DropdownMenuItem(
                  value: category.categoryId,
                  child: Text(category.categoryName),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
        if (_categories.isEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            '⚠️ No categories found in database. Create them in Firestore or log in as Admin to add them first.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        SizedBox(height: AppTheme.spacing16),
        // Years of Experience
        CustomTextField(
          label: AppStrings.yearsOfExperience,
          hint: 'Enter years of experience',
          controller: _yearsExperienceController,
          keyboardType: TextInputType.number,
          prefixIcon: Icon(Icons.work),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Years of experience is required';
            }
            if (int.tryParse(value!) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        // Service Description
        CustomTextField(
          label: AppStrings.serviceDescription,
          hint: 'Describe your services',
          controller: _serviceDescriptionController,
          maxLines: 4,
          prefixIcon: Icon(Icons.description),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Service description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.state,
          hint: 'Enter your state',
          controller: _stateController,
          prefixIcon: Icon(Icons.location_on),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'State is required';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.lga,
          hint: 'Enter your LGA',
          controller: _lgaController,
          prefixIcon: Icon(Icons.location_on),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'LGA is required';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.address,
          hint: 'Enter your address',
          controller: _addressController,
          maxLines: 2,
          prefixIcon: Icon(Icons.location_on),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Address is required';
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing16),
        // Get Location Button
        OutlinedButton.icon(
          onPressed: _getLocation,
          icon: Icon(Icons.gps_fixed),
          label: Text('Get Current Location'),
        ),
        if (_latitude != 0.0 && _longitude != 0.0)
          Padding(
            padding: EdgeInsets.only(top: AppTheme.spacing16),
            child: Text(
              'Location: $_latitude, $_longitude',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
