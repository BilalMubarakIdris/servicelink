import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/firebase_config.dart';
import 'config/routes.dart';
import 'controllers/auth_controller.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';
import 'utils/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase();

  await initServices();

  runApp(const ServiceLinkApp());
}

Future<void> initServices() async {
  await Get.putAsync<FirebaseService>(() async {
    final service = FirebaseService();
    return service;
  });
  Get.put(AuthController());
}

class ServiceLinkApp extends StatelessWidget {
  const ServiceLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
    );
  }
}
