import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_type_screen.dart';
import '../screens/auth/signup_user_screen.dart';
import '../screens/auth/signup_provider_screen.dart';
import '../screens/user/user_home_screen.dart';
import '../screens/user/provider_detail_screen.dart';
import '../screens/user/create_request_screen.dart';
import '../screens/user/user_requests_screen.dart';
import '../screens/user/user_profile_screen.dart';
import '../screens/user/notifications_screen.dart';
import '../screens/provider/provider_home_screen.dart';
import '../screens/provider/provider_pending_screen.dart';
import '../screens/provider/provider_profile_screen.dart';
import '../screens/provider/provider_reviews_screen.dart';
import '../screens/provider/provider_requests_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_provider_approval_screen.dart';
import '../screens/admin/admin_providers_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../controllers/user_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/provider_controller.dart';
import '../controllers/notification_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signupType = '/signup-type';
  static const String signupUser = '/signup-user';
  static const String signupProvider = '/signup-provider';

  static const String userHome = '/user-home';
  static const String providerDetail = '/provider-detail';
  static const String createRequest = '/create-request';
  static const String serviceRequests = '/service-requests';
  static const String userProfile = '/user-profile';
  static const String notifications = '/notifications';

  static const String providerHome = '/provider-home';
  static const String providerPending = '/provider-pending';
  static const String providerProfile = '/provider-profile';
  static const String providerReviews = '/provider-reviews';
  static const String providerRequests = '/provider-requests';

  static const String adminHome = '/admin-home';
  static const String adminProviderApproval = '/admin-provider-approval';
  static const String adminProviders = '/admin-providers';
  static const String adminUsers = '/admin-users';
  static const String adminCategories = '/admin-categories';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signupType,
      page: () => const SignUpTypeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signupUser,
      page: () => const SignUpUserScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signupProvider,
      page: () => const SignUpProviderScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: userHome,
      page: () => const UserHomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserController>()) {
          Get.put(UserController());
        }
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerDetail,
      page: () => const ProviderDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createRequest,
      page: () => const CreateRequestScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserController>()) {
          Get.put(UserController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: serviceRequests,
      page: () => const UserRequestsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserController>()) {
          Get.put(UserController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: userProfile,
      page: () => const UserProfileScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserController>()) {
          Get.put(UserController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerHome,
      page: () => const ProviderHomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProviderController>()) {
          Get.put(ProviderController());
        }
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerPending,
      page: () => const ProviderPendingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerProfile,
      page: () => const ProviderProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerReviews,
      page: () => const ProviderReviewsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providerRequests,
      page: () => const ProviderRequestsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminHome,
      page: () => const AdminHomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminController>()) {
          Get.put(AdminController());
        }
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminProviderApproval,
      page: () => const AdminProviderApprovalScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminProviders,
      page: () => const AdminProvidersScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminUsers,
      page: () => const AdminUsersScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminCategories,
      page: () => const AdminCategoriesScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
