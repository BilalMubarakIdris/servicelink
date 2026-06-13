import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:uuid/uuid.dart';
import '../config/routes.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final firebaseService = FirebaseService.instance;

  final Rx<firebase_auth.User?> firebaseUser = Rx<firebase_auth.User?>(null);
  final Rx<User?> appUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUser();
  }

  void _checkUser() async {
    final user = firebaseService.getCurrentUser();
    if (user != null) {
      firebaseUser.value = user;
      await _getAppUser(user.uid);
      _routeByRole();
    }
  }

  Future<void> _getAppUser(String uid) async {
    try {
      final user = await firebaseService.getUser(uid);
      if (user != null) {
        appUser.value = user;
        userRole.value = user.role;
      }
    } catch (e) {
      print('Error getting app user: $e');
    }
  }

  Future<void> _routeByRole() async {
    final user = appUser.value;
    if (user == null) return;

    if (user.role == AppConstants.roleUser) {
      Get.offAllNamed(AppRoutes.userHome);
    } else if (user.role == AppConstants.roleProvider) {
      await _routeProvider();
    } else if (user.role == AppConstants.roleAdmin) {
      Get.offAllNamed(AppRoutes.adminHome);
    }
  }

  Future<void> _routeProvider() async {
    final uid = appUser.value?.uid;
    if (uid == null) return;

    final provider = await firebaseService.getProviderByUserId(uid);
    if (provider == null ||
        provider.approvalStatus == AppConstants.statusPending ||
        provider.approvalStatus == AppConstants.statusRejected ||
        provider.approvalStatus == AppConstants.statusSuspended) {
      Get.offAllNamed(AppRoutes.providerPending);
    } else {
      Get.offAllNamed(AppRoutes.providerHome);
    }
  }

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await firebaseService.registerWithEmail(
        email,
        password,
      );

      final newUser = User(
        uid: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
      );

      await firebaseService.createUser(newUser);
      appUser.value = newUser;
      userRole.value = AppConstants.roleUser;
      firebaseUser.value = userCredential.user;

      Get.offAllNamed(AppRoutes.userHome);
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerProvider({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String categoryId,
    required int yearsOfExperience,
    required String serviceDescription,
    required String state,
    required String lga,
    required String address,
    required double latitude,
    required double longitude,
    String? profileImagePath,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await firebaseService.registerWithEmail(
        email,
        password,
      );
      final uid = userCredential.user!.uid;

      String? profilePictureUrl;
      if (profileImagePath != null) {
        profilePictureUrl = await firebaseService.uploadProfilePicture(
          profileImagePath,
          uid,
        );
      }

      final newUser = User(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: AppConstants.roleProvider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
        profilePictureUrl: profilePictureUrl,
      );

      await firebaseService.createUser(newUser);

      final providerId = const Uuid().v4();
      final provider = Provider(
        providerId: providerId,
        userId: uid,
        categoryId: categoryId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        yearsOfExperience: yearsOfExperience,
        serviceDescription: serviceDescription,
        state: state,
        localGovernmentArea: lga,
        address: address,
        latitude: latitude,
        longitude: longitude,
        profilePictureUrl: profilePictureUrl,
        approvalStatus: AppConstants.statusPending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firebaseService.createProvider(provider);
      appUser.value = newUser;
      userRole.value = AppConstants.roleProvider;
      firebaseUser.value = userCredential.user;

      Get.offAllNamed(AppRoutes.providerPending);
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await firebaseService.loginWithEmail(
        email,
        password,
      );

      final user = await firebaseService.getUser(userCredential.user!.uid);

      if (user != null) {
        appUser.value = user;
        userRole.value = user.role;
        firebaseUser.value = userCredential.user;
        await _routeByRole();
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await firebaseService.logout();
      appUser.value = null;
      firebaseUser.value = null;
      userRole.value = '';
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool get isUserLoggedIn => firebaseUser.value != null;
  bool get isUser => userRole.value == AppConstants.roleUser;
  bool get isProvider => userRole.value == AppConstants.roleProvider;
  bool get isAdmin => userRole.value == AppConstants.roleAdmin;

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await firebaseService.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
