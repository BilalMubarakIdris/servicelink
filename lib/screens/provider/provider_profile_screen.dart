import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/provider_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late final ProviderController providerController;
  final authController = AuthController.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stateController = TextEditingController();
  final _lgaController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCategoryId;
  String? _profileImagePath;
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    providerController = Get.find<ProviderController>();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    await providerController.loadProviderData();

    final provider = providerController.currentProvider.value;
    if (provider != null) {
      _selectedCategoryId = provider.categoryId;
      _nameController.text = provider.fullName;
      _phoneController.text = provider.phoneNumber;
      _experienceController.text = provider.yearsOfExperience.toString();
      _descriptionController.text = provider.serviceDescription;
      _stateController.text = provider.state;
      _lgaController.text = provider.localGovernmentArea;
      _addressController.text = provider.address;
      _latitude = provider.latitude;
      _longitude = provider.longitude;
    }

    await providerController.loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _stateController.dispose();
    _lgaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    Get.snackbar('Success', 'Location captured');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      Get.snackbar('Error', 'Category not loaded yet. Please wait.');
      return;
    }

    final experience = int.tryParse(_experienceController.text);
    if (experience == null) {
      Get.snackbar('Error', 'Invalid years of experience');
      return;
    }

    final success = await providerController.updateProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      categoryId: _selectedCategoryId!,
      yearsOfExperience: experience,
      serviceDescription: _descriptionController.text.trim(),
      state: _stateController.text.trim(),
      lga: _lgaController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      profileImagePath: _profileImagePath,
    );

    if (success) {
      Get.back();
    } else {
      Get.snackbar('Error', 'Failed to update profile. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(
            () => CustomButton(
              text: AppStrings.save,
              onPressed: _saveProfile,
              isLoading: providerController.isSubmitting.value,
              width: 80,
              height: 36,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (providerController.isLoading.value) {
          return const Center(
            child: CustomLoadingIndicator(message: AppStrings.loading),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePictureSection(),
                SizedBox(height: AppTheme.spacing24),
                _buildPersonalInfoSection(),
                SizedBox(height: AppTheme.spacing24),
                _buildServiceInfoSection(),
                SizedBox(height: AppTheme.spacing24),
                _buildLocationSection(),
                SizedBox(height: AppTheme.spacing32),
                CustomButton(
                  text: AppStrings.save,
                  onPressed: _saveProfile,
                  isLoading: providerController.isSubmitting.value,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfilePictureSection() {
    final provider = providerController.currentProvider.value;
    final imageUrl = _profileImagePath != null
        ? null
        : provider?.profilePictureUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: _profileImagePath != null
              ? ClipOval(
                  child: kIsWeb
                      ? Image.network(
                          _profileImagePath!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_profileImagePath!),
                          fit: BoxFit.cover,
                        ),
                )
              : imageUrl == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomButton(
          text: AppStrings.uploadPhoto,
          onPressed: _pickImage,
          width: 150,
          height: 36,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.fullName,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomTextField(
          label: AppStrings.phoneNumber,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServiceInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>(
                label: AppStrings.serviceCategory,
                value: _selectedCategoryId,
                items: providerController.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.categoryId,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              if (providerController.categories.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ No categories found in database. Create them in Firestore or log in as Admin to add them first.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomTextField(
          label: AppStrings.yearsOfExperience,
          controller: _experienceController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Experience is required';
            }
            if (int.tryParse(value) == null || int.parse(value) < 0) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomTextField(
          label: AppStrings.serviceDescription,
          controller: _descriptionController,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.spacing16),
        CustomTextField(
          label: AppStrings.state,
          controller: _stateController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'State is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomTextField(
          label: AppStrings.lga,
          controller: _lgaController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'LGA is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing12),
        CustomTextField(
          label: AppStrings.address,
          controller: _addressController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Get Current Location',
                onPressed: _getCurrentLocation,
                height: 36,
              ),
            ),
          ],
        ),
        if (_latitude != 0.0 && _longitude != 0.0) ...[
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Location: $_latitude, $_longitude',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
