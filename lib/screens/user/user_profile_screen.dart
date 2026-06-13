import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/themes.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final authController = AuthController.instance;
  final firebaseService = FirebaseService.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = authController.appUser.value;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = authController.appUser.value;
    if (user == null) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      String? profilePictureUrl = user.profilePictureUrl;
      if (_profileImagePath != null) {
        profilePictureUrl = await firebaseService.uploadProfilePicture(
          _profileImagePath!,
          user.uid,
        );
      }

      await firebaseService.updateUser(user.uid, {
        'fullName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'profilePictureUrl': profilePictureUrl,
      });

      Get.back();
      Get.snackbar('Success', 'Profile updated');

      // Reload user data
      final updatedUser = await firebaseService.getUser(user.uid);
      if (updatedUser != null) {
        authController.appUser.value = updatedUser;
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(onPressed: _saveProfile, child: const Text('Save')),
        ],
      ),
      body: Obx(() {
        final user = authController.appUser.value;

        if (user == null) {
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
                _buildProfilePictureSection(user),
                SizedBox(height: AppTheme.spacing24),
                _buildPersonalInfoSection(),
                SizedBox(height: AppTheme.spacing32),
                CustomButton(text: AppStrings.save, onPressed: _saveProfile),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfilePictureSection(User user) {
    final imageUrl = _profileImagePath != null ? null : user.profilePictureUrl;

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
          label: 'Email',
          controller: TextEditingController(
            text: authController.appUser.value?.email,
          ),
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
}
