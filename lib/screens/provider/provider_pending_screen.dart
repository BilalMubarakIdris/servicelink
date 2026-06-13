import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/themes.dart';
import '../../widgets/common_widgets.dart';

class ProviderPendingScreen extends StatefulWidget {
  const ProviderPendingScreen({super.key});

  @override
  State<ProviderPendingScreen> createState() => _ProviderPendingScreenState();
}

class _ProviderPendingScreenState extends State<ProviderPendingScreen> {
  final authController = AuthController.instance;
  final firebaseService = FirebaseService.instance;
  String _status = AppConstants.statusPending;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final uid = authController.appUser.value?.uid;
    if (uid == null) return;

    final provider = await firebaseService.getProviderByUserId(uid);
    if (provider != null && mounted) {
      setState(() => _status = provider.approvalStatus);

      if (provider.approvalStatus == AppConstants.statusApproved) {
        Get.offAllNamed(AppRoutes.providerHome);
      }
    }
  }

  String get _message {
    switch (_status) {
      case AppConstants.statusRejected:
        return 'Your application was rejected. Please update your profile and try again.';
      case AppConstants.statusSuspended:
        return 'Your account has been suspended. Contact support for assistance.';
      default:
        return 'Your application is under review. You will be notified once an administrator approves your account.';
    }
  }

  IconData get _icon {
    switch (_status) {
      case AppConstants.statusRejected:
        return Icons.cancel;
      case AppConstants.statusSuspended:
        return Icons.block;
      default:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatus,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 80, color: AppTheme.primaryColor),
            SizedBox(height: AppTheme.spacing24),
            Text(
              _status.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: AppTheme.spacing32),
            CustomButton(
              text: 'Check Status',
              onPressed: _loadStatus,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
