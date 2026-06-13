import '../models/category_model.dart';

class AppConstants {
  // App Info
  static const String appName = 'ServiceLink';
  static const String appVersion = '1.0.0';

  static List<Category> get defaultCategories => [
    Category(categoryId: 'electrician', categoryName: 'Electrician', description: 'Electrical installation & repairs'),
    Category(categoryId: 'plumber', categoryName: 'Plumber', description: 'Plumbing installations & repairs'),
    Category(categoryId: 'carpenter', categoryName: 'Carpenter', description: 'Woodworking & furniture building'),
    Category(categoryId: 'painter', categoryName: 'Painter', description: 'Wall painting & decoration'),
    Category(categoryId: 'cleaner', categoryName: 'Cleaner', description: 'House & office cleaning services'),
  ];

  // API Routes
  static const String usersCollection = 'users';
  static const String providersCollection = 'providers';
  static const String categoriesCollection = 'categories';
  static const String serviceRequestsCollection = 'service_requests';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';

  // User Roles
  static const String roleUser = 'user';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // Approval Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusSuspended = 'suspended';

  // Request Status
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  static const String requestInProgress = 'inProgress';
  static const String requestCompleted = 'completed';
  static const String requestCancelled = 'cancelled';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;

  // Storage Paths
  static const String storageProfilePictures = 'profile_pictures/';
  static const String storageProviderProfiles = 'provider_profiles/';

  // Pagination
  static const int pageSize = 20;
}

class AppStrings {
  // Welcome Screen
  static const String welcome = 'Welcome to ServiceLink';
  static const String welcomeDesc =
      'Connect with verified local service providers';

  // Auth Strings
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Provider Signup
  static const String serviceCategory = 'Service Category';
  static const String yearsOfExperience = 'Years of Experience';
  static const String serviceDescription = 'Service Description';
  static const String state = 'State';
  static const String lga = 'Local Government Area';
  static const String address = 'Address';
  static const String uploadPhoto = 'Upload Photo';
  static const String selectCategory = 'Select a category';

  // User Home
  static const String searchProviders = 'Search Providers';
  static const String categories = 'Categories';
  static const String nearbyProviders = 'Nearby Providers';
  static const String allProviders = 'All Providers';

  // Buttons
  static const String next = 'Next';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String logout = 'Logout';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String view = 'View';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String accept = 'Accept';
  static const String complete = 'Complete';

  // Messages
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String error = 'An error occurred';
  static const String success = 'Success';
  static const String failed = 'Failed';
}
